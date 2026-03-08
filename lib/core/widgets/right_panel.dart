import 'package:flutter/material.dart';

class RightPanel extends StatelessWidget {
  const RightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: const Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Right Panel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}



