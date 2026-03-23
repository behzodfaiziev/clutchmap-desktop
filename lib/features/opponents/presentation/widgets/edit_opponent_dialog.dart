import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/opponent_bloc.dart';
import '../bloc/opponent_event.dart';
import '../bloc/opponent_state.dart';

class EditOpponentDialog extends StatefulWidget {
  final String opponentId;
  final String initialName;
  final String? initialRegion;
  final String? initialNotes;

  const EditOpponentDialog({
    super.key,
    required this.opponentId,
    required this.initialName,
    this.initialRegion,
    this.initialNotes,
  });

  @override
  State<EditOpponentDialog> createState() => _EditOpponentDialogState();
}

class _EditOpponentDialogState extends State<EditOpponentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _regionController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _regionController = TextEditingController(text: widget.initialRegion ?? '');
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Opponent'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _regionController,
                decoration: const InputDecoration(
                  labelText: 'Region (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        BlocListener<OpponentBloc, OpponentState>(
          listenWhen: (previous, current) =>
              current is OpponentLoadedState && previous is OpponentLoading,
          listener: (context, state) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opponent updated')),
            );
          },
          child: BlocListener<OpponentBloc, OpponentState>(
            listenWhen: (previous, current) => current is OpponentError,
            listener: (context, state) {
              if (state is OpponentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context.read<OpponentBloc>().add(
                        OpponentUpdated(
                          opponentId: widget.opponentId,
                          name: _nameController.text.trim(),
                          region: _regionController.text.trim().isEmpty
                              ? null
                              : _regionController.text.trim(),
                          notes: _notesController.text.trim().isEmpty
                              ? null
                              : _notesController.text.trim(),
                        ),
                      );
                }
              },
              child: const Text('Update'),
            ),
          ),
        ),
      ],
    );
  }
}
