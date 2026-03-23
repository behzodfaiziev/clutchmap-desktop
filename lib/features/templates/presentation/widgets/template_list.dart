import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/strategy_template.dart';
import '../bloc/template_bloc.dart';
import '../bloc/template_event.dart';

class TemplateList extends StatelessWidget {
  final List<StrategyTemplate> templates;

  const TemplateList({super.key, required this.templates});

  void _onCreateFromMatchPressed(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create template from match'),
        content: const Text(
          'To create a template, open a match from the Matches page and use "Save as Template" in the workspace.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/matches');
            },
            child: const Text('Go to Matches'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Templates',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _onCreateFromMatchPressed(context),
                icon: const Icon(Icons.add),
                label: const Text('Create From Match'),
              ),
            ],
          ),
        ),
        Expanded(
          child: templates.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 56,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No templates found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Save a match as a template from the workspace',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => _onCreateFromMatchPressed(context),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Create From Match'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(template.name),
                        subtitle: template.mapName != null
                            ? Text("Map: ${template.mapName}")
                            : null,
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          context
                              .read<TemplateBloc>()
                              .add(TemplateSelected(template.id, templateFromList: template));
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}


