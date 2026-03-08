import 'package:flutter/material.dart';

enum ConflictResolution {
  reload,
  keepDraft,
}

Future<ConflictResolution?> showVersionConflictDialog(BuildContext context) async {
  final result = await showDialog<ConflictResolution>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Version Conflict"),
      content: const Text(
        "Another user updated this round. "
        "Reload latest version or keep your draft?",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(ConflictResolution.keepDraft),
          child: const Text("Keep My Draft"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(ConflictResolution.reload),
          child: const Text("Reload"),
        ),
      ],
    ),
  );
  return result;
}


