import 'package:flutter/material.dart';

class SystemSection extends StatelessWidget {
  final String? appVersion;
  final String? backendVersion;

  const SystemSection({
    super.key,
    this.appVersion,
    this.backendVersion,
  });

  @override
  Widget build(BuildContext context) {
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
          ListTile(
            title: const Text('Backend Version'),
            trailing: Text(
              backendVersion ?? 'Loading...',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



