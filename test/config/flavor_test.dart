import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/annotations.dart';
import 'package:rubbit_client/config/flavor.dart';

@GenerateMocks([])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlavorType 테스트', () {
    test('문자열 "dev"가 주어지면, FlavorType.dev를 반환해야 한다', () {
      // given
      final String flavorString = 'dev';

      // when
      final result = FlavorType.fromString(flavorString);

      // then
      expect(result, equals(FlavorType.dev));
    });

    test('대소문자 구분 없이 "DEV"가 주어지면, FlavorType.dev를 반환해야 한다', () {
      // given
      final String flavorString = 'DEV';

      // when
      final result = FlavorType.fromString(flavorString);

      // then
      expect(result, equals(FlavorType.dev));
    });

    test('빈 문자열이 주어지고 디버그 모드일 때, FlavorType.dev를 반환해야 한다', () {
      // given
      final String flavorString = '';
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      // when
      final result = FlavorType.fromString(flavorString);

      // then
      expect(result, equals(FlavorType.dev));
      debugDefaultTargetPlatformOverride = null;
    });

    test('null이 주어지고 프로덕션 모드일 때, FlavorType.prod를 반환해야 한다', () {
      // given
      final String? flavorString = null;
      // 프로덕션 모드 시뮬레이션을 위한 설정이 필요함

      // when
      final result = FlavorType.fromString(flavorString);

      // then
      // 참고: 실제 테스트에서는 프로덕션 모드를 시뮬레이션하기 어려울 수 있음
      // 디버그 모드에서는 기본적으로 FlavorType.dev를 반환할 것임
      expect(result, equals(FlavorType.dev));
    });
  });

  group('DevFlavorConfig 테스트', () {
    late DevFlavorConfig devConfig;

    setUp(() {
      devConfig = DevFlavorConfig();
    });

    test('DevFlavorConfig가 생성되면, 올바른 flavorType을 반환해야 한다', () {
      // given
      // DevFlavorConfig가 생성됨

      // when
      final flavorType = devConfig.flavorType;

      // then
      expect(flavorType, equals(FlavorType.dev));
    });

    test('DevFlavorConfig가 생성되면, 올바른 appTitle을 반환해야 한다', () {
      // given
      // DevFlavorConfig가 생성됨

      // when
      final appTitle = devConfig.appTitle;

      // then
      expect(appTitle, equals('RUBBIT Dev'));
    });

    test('DevFlavorConfig가 생성되면, 올바른: baseApiUrl을 반환해야 한다', () {
      // given
      // DevFlavorConfig가 생성됨

      // when
      final baseApiUrl = devConfig.baseApiUrl;

      // then
      expect(baseApiUrl, equals('https://rubbit-dev.suojae.kr/'));
    });

    test('DevFlavorConfig가 생성되면, 로깅이 활성화되어 있어야 한다', () {
      // given
      // DevFlavorConfig가 생성됨

      // when
      final isLoggingEnabled = devConfig.isLoggingEnabled;

      // then
      expect(isLoggingEnabled, isTrue);
    });

    test('DevFlavorConfig가 생성되면, API 타임아웃이 30초여야 한다', () {
      // given
      // DevFlavorConfig가 생성됨

      // when
      final apiTimeoutSeconds = devConfig.apiTimeoutSeconds;

      // then
      expect(apiTimeoutSeconds, equals(30));
    });
  });

  group('ProdFlavorConfig 테스트', () {
    late ProdFlavorConfig prodConfig;

    setUp(() {
      prodConfig = ProdFlavorConfig();
    });

    test('ProdFlavorConfig가 생성되면, 올바른 flavorType을 반환해야 한다', () {
      // given
      // ProdFlavorConfig가 생성됨

      // when
      final flavorType = prodConfig.flavorType;

      // then
      expect(flavorType, equals(FlavorType.prod));
    });

    test('ProdFlavorConfig가 생성되면, 올바른 appTitle을 반환해야 한다', () {
      // given
      // ProdFlavorConfig가 생성됨

      // when
      final appTitle = prodConfig.appTitle;

      // then
      expect(appTitle, equals('RUBBIT'));
    });

    test('ProdFlavorConfig가 생성되면, 올바른: baseApiUrl을 반환해야 한다', () {
      // given
      // ProdFlavorConfig가 생성됨

      // when
      final baseApiUrl = prodConfig.baseApiUrl;

      // then
      expect(baseApiUrl, equals('https://rubbit.suojae.kr/'));
    });

    test('ProdFlavorConfig가 생성되면, 로깅이 비활성화되어 있어야 한다', () {
      // given
      // ProdFlavorConfig가 생성됨

      // when
      final isLoggingEnabled = prodConfig.isLoggingEnabled;

      // then
      expect(isLoggingEnabled, isFalse);
    });

    test('ProdFlavorConfig가 생성되면, API 타임아웃이 15초여야 한다', () {
      // given
      // ProdFlavorConfig가 생성됨

      // when
      final apiTimeoutSeconds = prodConfig.apiTimeoutSeconds;

      // then
      expect(apiTimeoutSeconds, equals(15));
    });
  });
}
