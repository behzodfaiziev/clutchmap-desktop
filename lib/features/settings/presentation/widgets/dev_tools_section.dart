import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DevToolsSection extends StatelessWidget {
  final Map<String, dynamic>? capabilities;
  final String? capabilitiesError;

  const DevToolsSection({
    super.key,
    this.capabilities,
    this.capabilitiesError,
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
          ListTile(
            leading: const Icon(Icons.wifi_tethering),
            title: const Text('Test backend connectivity'),
            subtitle: const Text('Health & capabilities'),
            onTap: () => context.go('/test'),
          ),
          if (capabilitiesError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, size: 20, color: Colors.red.shade300),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      capabilitiesError!,
                      style: TextStyle(color: Colors.red.shade300, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else if (features != null) ...[
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



