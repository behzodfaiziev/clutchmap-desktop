import 'package:flutter/material.dart';

class SystemSection extends StatelessWidget {
  final String? appVersion;
  final String? backendVersion;
  final String? backendVersionError;
  /// Backend base URL (e.g. from ApiConfig.baseUrl) for environment label.
  final String? backendBaseUrl;

  const SystemSection({
    super.key,
    this.appVersion,
    this.backendVersion,
    this.backendVersionError,
    this.backendBaseUrl,
  });

  /// Derives a short environment label from base URL (DAY_125: dev/staging/prod).
  static String environmentLabel(String baseUrl) {
    final lower = baseUrl.toLowerCase();
    if (lower.contains('localhost') || lower.contains('127.0.0.1')) return 'Local';
    if (lower.contains('staging')) return 'Staging';
    return 'Production';
  }

  /// Extracts host part for display (e.g. localhost:8080, api.example.com).
  static String hostFromUrl(String baseUrl) {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null) return baseUrl;
    if (uri.port != 80 && uri.port != 443 && uri.port > 0) {
      return '${uri.host}:${uri.port}';
    }
    return uri.host;
  }

  @override
  Widget build(BuildContext context) {
    final envLabel = backendBaseUrl != null ? environmentLabel(backendBaseUrl!) : null;
    final host = backendBaseUrl != null ? hostFromUrl(backendBaseUrl!) : null;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'System',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text('App Version'),
            trailing: Text(
              appVersion ?? 'Loading...',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          if (backendBaseUrl != null)
            ListTile(
              title: const Text('Backend'),
              trailing: Text(
                envLabel != null ? '$envLabel ($host)' : host!,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ListTile(
            title: const Text('Backend Version'),
            trailing: Text(
              backendVersion ?? (backendVersionError ?? 'Loading...'),
              style: TextStyle(
                color: backendVersionError != null ? Colors.red.shade700 : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



