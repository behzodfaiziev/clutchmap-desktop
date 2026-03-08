import 'package:flutter/material.dart';

class DevToolsSection extends StatelessWidget {
  final Map<String, dynamic>? capabilities;

  const DevToolsSection({
    super.key,
    this.capabilities,
  });

  @override
  Widget build(BuildContext context) {
    final features = capabilities?['features'] as Map<String, dynamic>?;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Dev Tools',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (features != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Capabilities:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...features.entries.map((entry) {
              final enabled = entry.value as bool? ?? false;
              return ListTile(
                title: Text(entry.key),
                trailing: Icon(
                  enabled ? Icons.check_circle : Icons.cancel,
                  color: enabled ? Colors.green : Colors.red,
                ),
              );
            }),
          ] else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Loading capabilities...'),
            ),
        ],
      ),
    );
  }
}



