import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:rubbit_client/auth/data/remote/auth_exception.dart';
import 'package:rubbit_client/auth/data/remote/user_dto.dart';
import 'package:rubbit_client/core/type/result.dart';

final class AuthService {
  final FirebaseAuth _firebaseAuth;
  final _authStateController =
      StreamController<Result<UserDto, AuthException>>.broadcast();
  final List<StreamSubscription<User?>> _subscriptions = [];

  AuthService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _subscriptions.add(
      _firebaseAuth
              .authStateChanges()
              .map(_mapUserToResult)
              .listen(_authStateController.add)
          as StreamSubscription<User?>,
    );
    _emitCurrentUser();
  }

  Stream<Result<UserDto, AuthException>> get authStateChanges =>
      _authStateController.stream;

  Future<Result<UserDto, AuthException>> signInWithGoogle() =>
      _executeAuthTask(() async {
        final googleProvider = GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithProvider(
          googleProvider,
        );

        return userCredential.user != null
            ? Result.success(UserDto.fromFirebaseUser(userCredential.user!))
            : Result.failure(ServerException());
      });

  Future<Result<UserDto, AuthException>> signInWithApple() =>
      _executeAuthTask(() async {
        final appleProvider =
            OAuthProvider('apple.com')
              ..addScope('email')
              ..addScope('name');

        final userCredential = await _firebaseAuth.signInWithProvider(
          appleProvider,
        );

        return userCredential.user != null
            ? Result.success(UserDto.fromFirebaseUser(userCredential.user!))
            : Result.failure(ServerException());
      });

  Future<Result<void, AuthException>> signOut() => _executeAuthTask(() async {
    await _firebaseAuth.signOut();
    return Result.success(null);
  });

  Result<UserDto, AuthException> getCurrentUser() {
    try {
      return _mapUserToResult(_firebaseAuth.currentUser);
    } catch (e) {
      return _mapErrorToResult(e, UserDto.empty());
    }
  }

  Future<void> dispose() async {
    await Future.wait(
      _subscriptions.map((subscription) => subscription.cancel()),
    );
    _subscriptions.clear();
    await _authStateController.close();
  }
}

extension FirebaseAuthServiceHelper on AuthService {
  Result<UserDto, AuthException> _mapUserToResult(User? user) =>
      user != null
          ? Result.success(UserDto.fromFirebaseUser(user))
          : Result.success(UserDto.empty());

  void _emitCurrentUser() =>
      _authStateController.add(_mapUserToResult(_firebaseAuth.currentUser));

  Future<Result<T, AuthException>> _executeAuthTask<T>(
    Future<Result<T, AuthException>> Function() task,
  ) async {
    try {
      return await task();
    } catch (e) {
      return _mapErrorToResult<T>(e);
    }
  }

  Result<T, AuthException> _mapErrorToResult<T>(
    dynamic error, [
    T? defaultValue,
  ]) {
    debugPrint('Firebase 오류: $error');

    if (error is FirebaseAuthException) {
      return Result.failure(_mapFirebaseAuthExceptionToAuthException(error));
    } else if (error is FirebaseException) {
      return Result.failure(
        AuthException.fromException({
          'code': error.code,
          'message': error.message,
        }),
      );
    }

    return Result.failure(AuthException.fromException(error));
  }

  AuthException _mapFirebaseAuthExceptionToAuthException(
    FirebaseAuthException error,
  ) {
    final Map<String, AuthException Function()> exceptionMap = {
      'email-already-in-use': () => EmailAlreadyInUseException(),
      'invalid-email': () => InvalidEmailException(),
      'operation-not-allowed': () => OperationNotAllowedException(),
      'user-disabled': () => UserDisabledException(),
      'user-not-found': () => UserNotFoundException(),
      'network-request-failed': () => NetworkException(),
    };

    return exceptionMap[error.code]?.call() ??
        AuthException.fromException(error);
  }
}
