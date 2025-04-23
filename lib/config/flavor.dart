import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' as services;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rubbit_client/config/firebase_options_dev.dart';
import 'package:rubbit_client/config/firebase_options_prod.dart';
import 'package:rubbit_client/config/flavor_type.dart';

abstract class FlavorConfig {
  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    _instance ??= _resolveFlavorConfig();
    return _instance!;
  }

  static FlavorConfig _resolveFlavorConfig() {
    final flavorString = const String.fromEnvironment(
      'FLAVOR',
      defaultValue: '',
    );

    final nativeFlavorString = services.appFlavor;
    final flavorType = FlavorType.fromString(
      flavorString.isNotEmpty ? flavorString : nativeFlavorString,
    );

    return switch (flavorType) {
      FlavorType.dev => DevFlavorConfig(),
      FlavorType.prod => ProdFlavorConfig(),
    };
  }

  /// 현재 Flavor 타입
  FlavorType get flavorType;

  /// 앱 제목
  String get appTitle;

  /// API 기본 URL
  String get baseApiUrl;

  /// Firebase 옵션
  FirebaseOptions get firebaseOptions;

  /// 로깅 활성화 여부
  bool get isLoggingEnabled;

  /// API 요청 타임아웃 (초)
  int get apiTimeoutSeconds;

  /// Flavor 특정 환경 변수 초기화
  Future<void> initialize() async {
    await dotenv.load(fileName: _envFileName);
  }

  /// 환경 변수 파일 이름
  String get _envFileName => '.env.${flavorType.name}';

  /// 환경 변수 값 조회
  String env(String key, {String defaultValue = ''}) {
    return dotenv.env[key] ?? defaultValue;
  }
}

/// 개발 환경 설정
class DevFlavorConfig extends FlavorConfig {
  @override
  FlavorType get flavorType => FlavorType.dev;

  @override
  String get appTitle => 'RUBBIT Dev';

  @override
  String get baseApiUrl => 'https://rubbit-dev.suojae.kr/';

  @override
  FirebaseOptions get firebaseOptions => DevFirebaseOptions.currentPlatform;

  @override
  bool get isLoggingEnabled => true;

  @override
  int get apiTimeoutSeconds => 30;
}

/// 프로덕션 환경 설정
class ProdFlavorConfig extends FlavorConfig {
  @override
  FlavorType get flavorType => FlavorType.prod;

  @override
  String get appTitle => 'RUBBIT';

  @override
  String get baseApiUrl => 'https://rubbit.suojae.kr/';

  @override
  FirebaseOptions get firebaseOptions => ProdFirebaseOptions.currentPlatform;

  @override
  bool get isLoggingEnabled => false;

  @override
  int get apiTimeoutSeconds => 15;
}
