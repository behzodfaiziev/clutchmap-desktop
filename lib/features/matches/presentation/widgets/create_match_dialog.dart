import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../opponents/infrastructure/datasources/opponent_remote_data_source.dart';
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
  String? _selectedOpponentId;
  List<Map<String, dynamic>> _opponents = [];
  bool _opponentsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOpponents();
  }

  Future<void> _loadOpponents() async {
    try {
      final list = await getIt<OpponentRemoteDataSource>().getOpponents();
      if (mounted) {
        setState(() {
          _opponents = list;
          _opponentsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _opponents = [];
          _opponentsLoading = false;
        });
      }
    }
  }

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
              _opponentsLoading
                  ? const InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Opponent',
                        border: OutlineInputBorder(),
                      ),
                      child: SizedBox(
                        height: 20,
                        child: LinearProgressIndicator(),
                      ),
                    )
                  : DropdownButtonFormField<String?>(
                      decoration: const InputDecoration(
                        labelText: 'Opponent (optional)',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedOpponentId,
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(_opponents.isEmpty ? 'No opponents yet' : 'No opponent'),
                        ),
                        ..._opponents.map((o) {
                          final id = o['id']?.toString() ?? '';
                          final name = o['name'] as String? ?? id;
                          return DropdownMenuItem<String?>(
                            value: id.isEmpty ? null : id,
                            child: Text(name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedOpponentId = value;
                        });
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
        BlocConsumer<MatchesBloc, MatchesState>(
          listener: (context, state) {
            if (state is MatchesLoadedState) {
              Navigator.pop(context);
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
          buildWhen: (previous, current) =>
              previous is MatchesLoading != current is MatchesLoading,
          builder: (context, state) {
            final loading = state is MatchesLoading;
            return FilledButton(
              onPressed: loading
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        context.read<MatchesBloc>().add(
                              MatchCreated(
                                title: _titleController.text,
                                mapId: _selectedMapId,
                                startingSide: _selectedStartingSide,
                                opponentId: _selectedOpponentId,
                              ),
                            );
                      }
                    },
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create'),
            );
          },
        ),
      ],
    );
  }
}

