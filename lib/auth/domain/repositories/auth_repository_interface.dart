import 'package:rubbit_client/auth/data/remote/auth_exception.dart';
import 'package:rubbit_client/auth/data/remote/user_dto.dart';
import 'package:rubbit_client/core/type/result.dart';

abstract interface class IAuthRepository {
  Stream<Result<UserDto, AuthException>> get authStateChanges;

  Future<Result<UserDto, AuthException>> signInWithGoogle();

  Future<Result<UserDto, AuthException>> signInWithApple();

  Future<Result<void, AuthException>> signOut();

  Result<UserDto, AuthException> getCurrentUser();
}
