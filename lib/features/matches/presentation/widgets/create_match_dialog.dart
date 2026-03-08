import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/matches_bloc.dart';
import '../bloc/matches_event.dart';
import '../bloc/matches_state.dart';

class CreateMatchDialog extends StatefulWidget {
  const CreateMatchDialog({super.key});

  @override
  State<CreateMatchDialog> createState() => _CreateMatchDialogState();
}

class _CreateMatchDialogState extends State<CreateMatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedMapId;
  String? _selectedStartingSide;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Match'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Starting Side',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'ATTACK', child: Text('Attack')),
                  DropdownMenuItem(value: 'DEFENSE', child: Text('Defense')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStartingSide = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Map selection would go here - for now, optional
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Map ID (optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _selectedMapId = value.isEmpty ? null : value;
                },
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
        BlocListener<MatchesBloc, MatchesState>(
          listener: (context, state) {
            if (state is MatchesLoadedState) {
              Navigator.pop(context);
              // Optionally navigate to the new match
              // context.go("/match/${newMatchId}");
            }
            if (state is MatchesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          listenWhen: (previous, current) => 
            current is MatchesLoadedState || current is MatchesError,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                context.read<MatchesBloc>().add(
                  MatchCreated(
                    title: _titleController.text,
                    mapId: _selectedMapId,
                    startingSide: _selectedStartingSide,
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ),
      ],
    );
  }
}

