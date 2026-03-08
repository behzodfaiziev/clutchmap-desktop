import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/di/injection.dart';

class TestConnectivityPage extends StatefulWidget {
  const TestConnectivityPage({super.key});

  @override
  State<TestConnectivityPage> createState() => _TestConnectivityPageState();
}

class _TestConnectivityPageState extends State<TestConnectivityPage> {
  String? _response;
  bool _loading = false;
  String? _error;

  Future<void> _testConnection() async {
    setState(() {
      _loading = true;
      _error = null;
      _response = null;
    });

    try {
      final dio = getIt<Dio>();
      final response = await dio.get('/system/capabilities');
      setState(() {
        _response = response.data.toString();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Connectivity Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _testConnection,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Test Connection'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red.shade900,
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            if (_response != null)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey.shade900,
                  child: SingleChildScrollView(
                    child: Text(
                      _response!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
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



