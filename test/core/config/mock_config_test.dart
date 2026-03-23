import 'package:flutter_test/flutter_test.dart';
import 'package:clutchmap_desktop/core/config/mock_config.dart';

void main() {
  group('MockConfig', () {
    test('useMockAuth returns default when no compile-time define is set', () {
      // Without --dart-define=USE_MOCK_AUTH, should use useMockAuthDefault
      expect(MockConfig.useMockAuth, equals(MockConfig.useMockAuthDefault));
    });

    test('useMockAuthDefault is true by default', () {
      expect(MockConfig.useMockAuthDefault, isTrue);
    });

    test('configSummary contains expected keys', () {
      final summary = MockConfig.configSummary;

      expect(summary, contains('useMockAuth'));
      expect(summary, contains('isDevelopment'));
      expect(summary, contains('isProduction'));
      expect(summary, contains('useMockAuthDefault'));

      expect(summary['useMockAuth'], isA<bool>());
      expect(summary['isDevelopment'], isA<bool>());
      expect(summary['isProduction'], isA<bool>());
      expect(summary['useMockAuthDefault'], isA<bool>());
    });

    test('configSummary useMockAuth matches useMockAuth getter', () {
      expect(
        MockConfig.configSummary['useMockAuth'],
        equals(MockConfig.useMockAuth),
      );
    });

    test('isDevelopment and isProduction are opposite', () {
      expect(
        MockConfig.isDevelopment,
        isNot(equals(MockConfig.isProduction)),
      );
    });
  });
}
