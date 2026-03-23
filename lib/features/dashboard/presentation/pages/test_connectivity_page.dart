import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/errors/backend_error_helper.dart';
import '../../../settings/infrastructure/datasources/system_remote_data_source.dart';

class TestConnectivityPage extends StatefulWidget {
  const TestConnectivityPage({super.key});

  @override
  State<TestConnectivityPage> createState() => _TestConnectivityPageState();
}

class _TestConnectivityPageState extends State<TestConnectivityPage> {
  String? _response;
  bool _loading = false;
  String? _error;

  Future<void> _testConnection({bool useHealth = false}) async {
    setState(() {
      _loading = true;
      _error = null;
      _response = null;
    });

    try {
      final systemDs = getIt<SystemRemoteDataSource>();
      final data = useHealth
          ? await systemDs.getHealth()
          : await systemDs.getCapabilities();
      setState(() {
        _response = data.toString();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = messageFromException(e, fallback: 'Connection failed');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Connectivity Test'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
          tooltip: 'Back to Settings',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Backend: ${ApiConfig.baseUrl}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : () => _testConnection(useHealth: false),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Capabilities'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _loading ? null : () => _testConnection(useHealth: true),
                  child: const Text('Health'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade700),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade300, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            if (_response != null && _error == null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade300, size: 22),
                    const SizedBox(width: 8),
                    Text('Connected', style: TextStyle(color: Colors.green.shade300, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            if (_response != null)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _response!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}



