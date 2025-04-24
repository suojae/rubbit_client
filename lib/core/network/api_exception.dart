class ApiException implements Exception {
  final String code;
  final String message;

  ApiException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'ApiException: [$code] $message';
}

/// 400 Bad Request 예외
class BadRequestException extends ApiException {
  BadRequestException({required super.code, required super.message});
}

/// 401 Unauthorized 예외
class UnauthorizedException extends ApiException {
  UnauthorizedException({required super.code, required super.message});
}

/// 403 Forbidden 예외
class ForbiddenException extends ApiException {
  ForbiddenException({required super.code, required super.message});
}

/// 404 Not Found 예외
class NotFoundException extends ApiException {
  NotFoundException({required super.code, required super.message});
}

/// 409 Conflict 예외
class ConflictException extends ApiException {
  ConflictException({required super.code, required super.message});
}

/// 422 Validation 예외
class ValidationException extends ApiException {
  final Map<String, String> errors;

  ValidationException({
    required super.code,
    required super.message,
    this.errors = const {},
  });

  @override
  String toString() {
    return 'ValidationException: [$code] $message, errors: $errors';
  }
}

/// 429 Too Many Requests 예외
class TooManyRequestsException extends ApiException {
  TooManyRequestsException({required super.code, required super.message});
}

/// 500 Server 예외
class ServerException extends ApiException {
  ServerException({required super.code, required super.message});
}

/// 네트워크 연결 예외
class NetworkException extends ApiException {
  NetworkException()
      : super(
    code: 'network_error',
    message: '네트워크 연결을 확인해주세요.',
  );
}

/// 타임아웃 예외
class TimeoutException extends ApiException {
  TimeoutException()
      : super(
    code: 'timeout',
    message: '요청 시간이 초과되었습니다.',
  );
}