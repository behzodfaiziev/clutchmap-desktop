import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/right_panel.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(width: 240, child: Sidebar()),
          Expanded(child: child),
          SizedBox(width: 300, child: RightPanel()),
        ],
      ),
    );
  }
}



