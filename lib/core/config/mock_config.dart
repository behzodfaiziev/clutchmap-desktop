import 'package:flutter/foundation.dart';

/// Configuration for mock data sources.
///
/// Allows switching between mock and real implementations via:
/// - Compile-time defines: `--dart-define=USE_MOCK_AUTH=true`
/// - Build-time constants
/// - Runtime flags
class MockConfig {
  /// Whether to use mock auth data source.
  ///
  /// Priority order:
  /// 1. Compile-time define: `--dart-define=USE_MOCK_AUTH=true/false`
  /// 2. Build-time constant: [useMockAuthDefault]
  ///
  /// Usage:
  /// ```bash
  /// flutter run --dart-define=USE_MOCK_AUTH=false
  /// ```
  static bool get useMockAuth {
    // Check compile-time define first
    const compileTimeValue = String.fromEnvironment(
      'USE_MOCK_AUTH',
      defaultValue: '',
    );
    if (compileTimeValue.isNotEmpty) {
      return _parseBool(compileTimeValue) ?? useMockAuthDefault;
    }

    // Fall back to default
    return useMockAuthDefault;
  }

  /// Default value for [useMockAuth] when no compile-time define is set.
  ///
  /// Set to `true` for development, `false` for production.
  /// Can be overridden at compile time with `--dart-define=USE_MOCK_AUTH=true/false`
  static const bool useMockAuthDefault = true;

  /// Parse a string value to boolean.
  ///
  /// Returns `true` for: 'true', '1', 'yes', 'on' (case-insensitive).
  /// Returns `false` for: 'false', '0', 'no', 'off' (case-insensitive).
  /// Returns `null` for unrecognized values.
  static bool? _parseBool(String value) {
    final lowerValue = value.toLowerCase().trim();
    if (lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes' || lowerValue == 'on') {
      return true;
    }
    if (lowerValue == 'false' || lowerValue == '0' || lowerValue == 'no' || lowerValue == 'off') {
      return false;
    }
    return null;
  }

  /// Check if running in development/debug mode.
  ///
  /// Uses Flutter's [kDebugMode] to determine if we're in debug mode.
  static bool get isDevelopment => kDebugMode;

  /// Check if running in release/production mode.
  static bool get isProduction => kReleaseMode;

  /// Get a summary of current mock configuration.
  ///
  /// Useful for debugging and logging.
  static Map<String, dynamic> get configSummary => {
        'useMockAuth': useMockAuth,
        'isDevelopment': isDevelopment,
        'isProduction': isProduction,
        'useMockAuthDefault': useMockAuthDefault,
      };
}
