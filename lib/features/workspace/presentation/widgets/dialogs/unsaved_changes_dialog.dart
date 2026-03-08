import 'package:flutter/material.dart';

Future<bool> showUnsavedChangesDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Unsaved Changes"),
      content: const Text("You have unsaved changes. Leave anyway?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Leave"),
        ),
      ],
    ),
  );
  return result ?? false;
}


