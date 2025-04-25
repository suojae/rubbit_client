class AuthException implements Exception {
  final String code;
  final String message;
  final dynamic exception;

  const AuthException({
    required this.code,
    required this.message,
    this.exception,
  });

  factory AuthException.fromException(dynamic exception) {
    if (exception is Map<String, dynamic>) {
      return AuthException(
        code: exception['code'] ?? 'unknown-error',
        message: exception['message'] ?? '알 수 없는 오류가 발생했습니다.',
        exception: exception,
      );
    }

    return AuthException(
      code: 'unknown-error',
      message: '알 수 없는 오류가 발생했습니다.',
      exception: exception,
    );
  }

  @override
  String toString() => 'AuthFailure: [$code] $message';
}

/// 사용자에 의한 취소 예외
class CancelledByUserException extends AuthException {
  const CancelledByUserException()
    : super(code: 'cancelled-by-user', message: '사용자에 의해 인증이 취소되었습니다.');
}

/// 서버 오류 예외
class ServerException extends AuthException {
  const ServerException()
    : super(code: 'server-error', message: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
}

/// 이메일 중복 예외
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
    : super(code: 'email-already-in-use', message: '이미 사용 중인 이메일입니다.');
}

/// 유효하지 않은 이메일 예외
class InvalidEmailException extends AuthException {
  const InvalidEmailException()
    : super(code: 'invalid-email', message: '유효하지 않은 이메일 형식입니다.');
}

/// 허용되지 않은 작업 예외
class OperationNotAllowedException extends AuthException {
  const OperationNotAllowedException()
    : super(code: 'operation-not-allowed', message: '해당 작업이 허용되지 않습니다.');
}

/// 사용자 계정 비활성화 예외
class UserDisabledException extends AuthException {
  const UserDisabledException()
    : super(code: 'user-disabled', message: '사용자 계정이 비활성화되었습니다.');
}

/// 사용자 찾을 수 없음 예외
class UserNotFoundException extends AuthException {
  const UserNotFoundException()
    : super(code: 'user-not-found', message: '등록되지 않은 사용자입니다.');
}

/// 네트워크 오류 예외
class NetworkException extends AuthException {
  const NetworkException()
    : super(code: 'network-error', message: '네트워크 연결 상태를 확인해주세요.');
}
