/// API connection configuration.
///
/// Use [baseUrl] when building the HTTP client (e.g. Dio BaseOptions).
/// Override at compile time: `--dart-define=API_BASE_URL=https://api.example.com/api/v1`
class ApiConfig {
  /// Base URL for the backend API (no trailing slash).
  ///
  /// Default: `http://localhost:8080/api/v1` (local backend).
  /// Override: `flutter run --dart-define=API_BASE_URL=https://api.example.com/api/v1`
  static String get baseUrl {
    const value = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080/api/v1',
    );
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  /// Root URL for the backend (no path). Used for public endpoints that live under /public/v1.
  ///
  /// Example: baseUrl = "http://localhost:8080/api/v1" => publicRootUrl = "http://localhost:8080"
  static String get publicRootUrl {
    final base = baseUrl;
    // Strip /api/v1 or /api/v1/ from end
    if (base.endsWith('/api/v1')) return base.substring(0, base.length - 7);
    if (base.endsWith('/api/v1/')) return base.substring(0, base.length - 8);
    return base;
  }

  /// Path for system health (relative to [baseUrl]). Use for connectivity checks.
  static String get systemHealthPath => '/system/health';

  /// Path for system capabilities (relative to [baseUrl]).
  static String get systemCapabilitiesPath => '/system/capabilities';

  /// WebSocket URL for strategy updates. Backend endpoint is /ws/strategy.
  /// Derived from [publicRootUrl]: http(s) -> ws(s), path /ws/strategy.
  static String webSocketUrl(String path) {
    final root = publicRootUrl;
    final scheme = root.startsWith('https') ? 'wss' : 'ws';
    final authority = root.replaceFirst(RegExp(r'^https?://'), '');
    return '$scheme://$authority${path.startsWith('/') ? path : '/$path'}';
  }

  /// Default WebSocket path used by the backend for strategy updates.
  static const String wsStrategyPath = '/ws/strategy';

  /// Connection timeout in milliseconds.
  static const int connectTimeoutMs = 30000;

  /// Receive timeout in milliseconds.
  static const int receiveTimeoutMs = 30000;
}
