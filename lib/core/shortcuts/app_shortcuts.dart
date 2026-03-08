import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../features/search/presentation/widgets/search_overlay.dart';

class OpenSearchIntent extends Intent {
  const OpenSearchIntent();
}

class AppShortcuts extends StatelessWidget {
  final Widget child;

  const AppShortcuts({
    super.key,
    required this.child,
  });

  void _showSearchOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SearchOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            const OpenSearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
            const NewMatchIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyB):
            const OpenBenchmarkIntent(),
      },
      child: Actions(
        actions: {
          OpenSearchIntent: CallbackAction<OpenSearchIntent>(
            onInvoke: (intent) {
              _showSearchOverlay(context);
            },
          ),
          NewMatchIntent: CallbackAction<NewMatchIntent>(
            onInvoke: (intent) {
              // Navigate to matches page and trigger create dialog
              context.go('/matches');
              // In production, you'd trigger the create dialog programmatically
            },
          ),
          OpenBenchmarkIntent: CallbackAction<OpenBenchmarkIntent>(
            onInvoke: (intent) {
              // Get teamId from context - in production, get from auth state
              // For now, placeholder
              // context.go('/benchmark/$teamId');
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class NewMatchIntent extends Intent {
  const NewMatchIntent();
}

class OpenBenchmarkIntent extends Intent {
  const OpenBenchmarkIntent();
}



