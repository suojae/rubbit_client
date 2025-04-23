import 'package:flutter/foundation.dart' show kDebugMode;

enum FlavorType {
  dev,
  prod;

  static FlavorType fromString(String? value) {
    return switch (value?.toLowerCase()) {
      "dev" => FlavorType.dev,
      _ => kDebugMode ? FlavorType.dev : FlavorType.prod,
    };
  }
}
