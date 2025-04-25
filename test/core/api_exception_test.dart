import 'package:flutter_test/flutter_test.dart';
import 'package:rubbit_client/core/network/api_exception.dart';

void main() {
  group('ApiException 공통 동작', () {
    test('Given code와 message가 주어진 ApiException '
        'When toString을 호출하면 '
        'Then "ApiException: [코드] 메시지" 형식이 반환된다.', () {
      var ex = ApiException(code: 'E001', message: '에러 발생');
      expect(ex.toString(), 'ApiException: [E001] 에러 발생');
    });
  });

  group('HTTP 상태별 예외 서브클래스', () {
    final Map<Type, ApiException> cases = {
      BadRequestException: BadRequestException(code: '400', message: '잘못된 요청'),
      UnauthorizedException: UnauthorizedException(
        code: '401',
        message: '인증 실패',
      ),
      ForbiddenException: ForbiddenException(code: '403', message: '권한 없음'),
      NotFoundException: NotFoundException(code: '404', message: '리소스 없음'),
      ConflictException: ConflictException(code: '409', message: '충돌 발생'),
      TooManyRequestsException: TooManyRequestsException(
        code: '429',
        message: '요청 과다',
      ),
      ServerException: ServerException(code: '500', message: '서버 오류'),
    };

    cases.forEach((type, ex) {
      test('Given ${type.toString()} 인스턴스 '
          'When code와 message를 조회하면 '
          'Then 생성 시 전달한 값이 반환된다.', () {
        expect(ex.code.isNotEmpty, isTrue);
        expect(ex.message.isNotEmpty, isTrue);
      });

      test('Given ${type.toString()} 인스턴스 '
          'When toString을 호출하면 '
          'Then "[$type.code] $type.message" 형식이 포함된다.', () {
        expect(ex.toString(), contains('[${ex.code}]'));
        expect(ex.toString(), contains(ex.message));
      });
    });
  });

  group('ValidationException 고유 동작', () {
    test('Given errors 맵이 주어진 ValidationException '
        'When toString을 호출하면 '
        'Then errors 내용이 문자열에 포함된다.', () {
      final ex = ValidationException(
        code: '422',
        message: '검증 실패',
        errors: {'email': '형식이 올바르지 않습니다.'},
      );

      expect(ex.errors['email'], '형식이 올바르지 않습니다.');
      expect(ex.toString(), contains('errors'));
      expect(ex.toString(), contains('email'));
    });
  });

  group('Network/Timeout 예외 기본값', () {
    test('Given NetworkException '
        'When 생성하면 '
        'Then 기본 code와 message가 설정된다.', () {
      final ex = NetworkException();
      expect(ex.code, 'network_error');
      expect(ex.message, '네트워크 연결을 확인해주세요.');
    });

    test('Given TimeoutException '
        'When 생성하면 '
        'Then 기본 code와 message가 설정된다.', () {
      final ex = TimeoutException();
      expect(ex.code, 'timeout');
      expect(ex.message, '요청 시간이 초과되었습니다.');
    });
  });
}
