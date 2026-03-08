import 'package:flutter/material.dart';

enum DraftRecoveryAction {
  restore,
  discard,
}

Future<DraftRecoveryAction?> showDraftRecoveryDialog(BuildContext context) async {
  final result = await showDialog<DraftRecoveryAction>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Recover Draft?"),
      content: const Text("We found unsaved changes from previous session."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(DraftRecoveryAction.discard),
          child: const Text("Discard"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(DraftRecoveryAction.restore),
          child: const Text("Restore"),
        ),
      ],
    ),
  );
  return result;
}


