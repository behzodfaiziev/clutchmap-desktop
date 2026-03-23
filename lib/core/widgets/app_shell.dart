import 'package:flutter/material.dart';
import '../di/injection.dart';
import '../team/active_team_service.dart';
import '../widgets/sidebar.dart';
import '../widgets/right_panel.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  /// When false, right panel is hidden (e.g. dashboard overview pixel-perfect).
  final bool showRightPanel;

  const AppShell({
    super.key,
    required this.child,
    this.showRightPanel = true,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    getIt<ActiveTeamService>().ensureResolved();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(child: widget.child),
          if (widget.showRightPanel) SizedBox(width: 300, child: RightPanel()),
        ],
      ),
    );
  }
}



