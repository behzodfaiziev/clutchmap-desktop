import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/notifications/toast_service.dart';
import '../../domain/entities/template_detail.dart';
import '../bloc/template_bloc.dart';
import '../bloc/template_event.dart';
import '../bloc/template_state.dart';

class TemplateDetailView extends StatefulWidget {
  final TemplateDetail template;

  const TemplateDetailView({super.key, required this.template});

  @override
  State<TemplateDetailView> createState() => _TemplateDetailViewState();
}

class _TemplateDetailViewState extends State<TemplateDetailView> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _applyTemplate() {
    if (_titleController.text.isEmpty) {
      ToastService.showError(context, 'Please enter a match title');
      return;
    }

    final bloc = context.read<TemplateBloc>();
    bloc.add(
      ApplyTemplate(
        widget.template.template.id,
        _titleController.text,
      ),
    );

    // Show loading and handle response
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocListener<TemplateBloc, TemplateState>(
        listener: (context, state) {
          if (state is TemplateError) {
            Navigator.of(dialogContext).pop(); // Close loading dialog
            ToastService.showError(context, state.message);
          } else if (state is TemplateLoadedState && state.createdMatchId != null) {
            Navigator.of(dialogContext).pop(); // Close loading dialog
            ToastService.showSuccess(context, 'Match created from template');
            context.pop(); // Go back to template list
            // Navigate to new match
            context.go("/match/${state.createdMatchId}");
          }
        },
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final template = widget.template.template;

    return Scaffold(
      appBar: AppBar(
        title: Text(template.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (template.mapName != null)
                      Text("Map: ${template.mapName}"),
                    if (widget.template.roundsCount > 0)
                      Text("Rounds: ${widget.template.roundsCount}"),
                    if (widget.template.aggressionScore != null)
                      Text(
                        "Aggression: ${widget.template.aggressionScore}",
                      ),
                    if (widget.template.structureScore != null)
                      Text(
                        "Structure: ${widget.template.structureScore}",
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Match Title',
                hintText: 'Enter title for new match',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyTemplate,
                child: const Text('Apply to New Match'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

