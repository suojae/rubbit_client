import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rubbit_client/config/flavor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlavorType.fromString', () {
    test(
      'Given 문자열이 "dev"인 경우 When fromString을 호출하면 Then FlavorType.dev가 반환된다.',
      () {
        const input = 'dev';
        final result = FlavorType.fromString(input);
        expect(result, FlavorType.dev);
      },
    );

    test(
      'Given 대소문자가 섞인 "DEV"인 경우 When fromString을 호출하면 Then FlavorType.dev가 반환된다.',
      () {
        const input = 'DEV';
        final result = FlavorType.fromString(input);
        expect(result, FlavorType.dev);
      },
    );

    test(
      'Given 지원되지 않는 문자열이고 kDebugMode=true인 환경 When fromString을 호출하면 Then FlavorType.dev가 반환된다.',
      () {
        const input = 'unexpected';
        final result = FlavorType.fromString(input);
        expect(kDebugMode, isTrue);
        expect(result, FlavorType.dev);
      },
    );
  });

  group('FlavorConfig.instance', () {
    test(
      'Given FLAVOR 미지정 & 디버그 모드 When instance를 호출하면 Then DevFlavorConfig가 반환된다.',
      () {
        final instance = FlavorConfig.instance;
        expect(instance, isA<DevFlavorConfig>());

        // 싱글턴 확인 (두 번째 호출도 동일 객체)
        final instance2 = FlavorConfig.instance;
        expect(identical(instance, instance2), isTrue);
      },
    );
  });

  group('DevFlavorConfig', () {
    final config = DevFlavorConfig();

    test('Given DevFlavorConfig 인스턴스 When 각 속성을 조회하면 Then 정의된 값이 반환된다.', () {
      expect(config.flavorType, FlavorType.dev);
      expect(config.appTitle, 'RUBBIT Dev');
      expect(config.baseApiUrl, 'https://rubbit-dev.suojae.kr/');
      expect(config.isLoggingEnabled, isTrue);
      expect(config.apiTimeoutSeconds, 30);
      expect(config.firebaseOptions, isNotNull);
    });

    test('Given 테스트용 env 값이 주입된 상태 When env()를 호출하면 Then 주입한 값을 돌려준다.', () {
      dotenv.testLoad(fileInput: 'TEST_KEY=dev-value');
      addTearDown(dotenv.clean);

      final value = config.env('TEST_KEY');
      expect(value, 'dev-value');
    });

    test('Given 존재하지 않는 키 When env()를 호출하면 Then 기본값을 돌려준다.', () {
      // Given – 초기화 (값은 비워둬도 OK)
      dotenv.testLoad(fileInput: '.env.dev');
      addTearDown(dotenv.clean);

      // When
      final value = config.env('UNKNOWN_KEY', defaultValue: 'fallback');

      // Then
      expect(value, 'fallback');
    });
  });

  group('ProdFlavorConfig', () {
    final config = ProdFlavorConfig();

    test('Given ProdFlavorConfig 인스턴스 When 각 속성을 조회하면 Then 정의된 값이 반환된다.', () {
      expect(config.flavorType, FlavorType.prod);
      expect(config.appTitle, 'RUBBIT');
      expect(config.baseApiUrl, 'https://rubbit.suojae.kr/');
      expect(config.isLoggingEnabled, isFalse);
      expect(config.apiTimeoutSeconds, 15);
      expect(config.firebaseOptions, isNotNull);
    });

    test('Given 테스트용 env 값이 주입된 상태 When env()를 호출하면 Then 주입한 값을 돌려준다.', () {
      dotenv.testLoad(fileInput: 'TEST_KEY=prod-value');
      addTearDown(dotenv.clean);

      final value = config.env('TEST_KEY');
      expect(value, 'prod-value');
    });

    test('Given 존재하지 않는 키 When env()를 호출하면 Then 기본값을 돌려준다.', () {
      // Given – 초기화 (값은 비워둬도 OK)
      dotenv.testLoad(fileInput: '.env.prod');
      addTearDown(dotenv.clean);

      // When
      final value = config.env('UNKNOWN_KEY', defaultValue: 'fallback');

      // Then
      expect(value, 'fallback');
    });
  });
}
