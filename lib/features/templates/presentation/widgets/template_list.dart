import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/strategy_template.dart';
import '../bloc/template_bloc.dart';
import '../bloc/template_event.dart';

class TemplateList extends StatelessWidget {
  final List<StrategyTemplate> templates;

  const TemplateList({super.key, required this.templates});

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
                onPressed: () {
                  // This would open a dialog to create from match
                  // For now, just show a message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Create template from match workspace'),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create From Match'),
              ),
            ],
          ),
        ),
        Expanded(
          child: templates.isEmpty
              ? const Center(
                  child: Text('No templates found'),
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
                              .add(TemplateSelected(template.id));
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


