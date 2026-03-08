import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/notifications/toast_service.dart';
import '../bloc/template_bloc.dart';
import '../bloc/template_event.dart';
import '../bloc/template_state.dart';

class CreateTemplateDialog extends StatefulWidget {
  final String matchId;

  const CreateTemplateDialog({super.key, required this.matchId});

  @override
  State<CreateTemplateDialog> createState() => _CreateTemplateDialogState();
}

class _CreateTemplateDialogState extends State<CreateTemplateDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createTemplate() {
    if (_nameController.text.isEmpty) {
      ToastService.showError(context, 'Please enter a template name');
      return;
    }

    // Create template using BLoC
    final bloc = context.read<TemplateBloc>();
    bloc.add(
      CreateTemplate(widget.matchId, _nameController.text),
    );

    Navigator.of(context).pop();
    
    // Listen for success - use mounted check
    bloc.stream.listen((state) {
      if (!mounted) return;
      if (state is TemplateError) {
        ToastService.showError(context, state.message);
      } else if (state is TemplateLoadedState) {
        ToastService.showSuccess(context, 'Template created successfully');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Template'),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Template name',
          labelText: 'Name',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _createTemplate(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createTemplate,
          child: const Text('Create'),
        ),
      ],
    );
  }
}

