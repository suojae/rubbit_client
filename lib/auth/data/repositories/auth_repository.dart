import 'package:rubbit_client/auth/data/remote/auth_exception.dart';
import 'package:rubbit_client/auth/data/remote/auth_service.dart';
import 'package:rubbit_client/auth/data/remote/user_dto.dart';
import 'package:rubbit_client/auth/domain/repositories/auth_repository_interface.dart';
import 'package:rubbit_client/core/type/result.dart';

final class AuthRepository implements IAuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  @override
  Stream<Result<UserDto, AuthException>> get authStateChanges =>
      _authService.authStateChanges;

  @override
  Future<Result<UserDto, AuthException>> signInWithGoogle() =>
      _authService.signInWithGoogle();

  @override
  Future<Result<UserDto, AuthException>> signInWithApple() =>
      _authService.signInWithApple();

  @override
  Future<Result<void, AuthException>> signOut() => _authService.signOut();

  @override
  Result<UserDto, AuthException> getCurrentUser() =>
      _authService.getCurrentUser();
}
