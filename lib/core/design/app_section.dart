import 'package:flutter/material.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppSection extends StatelessWidget {
  final String title;
  final Widget child;

  const AppSection({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.h2),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}


