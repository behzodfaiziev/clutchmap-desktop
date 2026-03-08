import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../infrastructure/datasources/template_remote_data_source.dart';
import '../bloc/template_bloc.dart';
import '../bloc/template_event.dart';
import '../bloc/template_state.dart';
import '../widgets/template_list.dart';
import '../widgets/template_detail_view.dart';

class TemplatesPage extends StatelessWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TemplateBloc(
        dataSource: TemplateRemoteDataSource(getIt<ApiClient>()),
      )..add(const TemplatesLoaded()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Templates'),
        ),
        body: BlocBuilder<TemplateBloc, TemplateState>(
          builder: (context, state) {
            if (state is TemplateLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TemplateError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TemplateBloc>().add(const TemplatesLoaded());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (state is TemplateLoadedState) {
              if (state.selectedTemplate != null) {
                return TemplateDetailView(template: state.selectedTemplate!);
              }
              return TemplateList(templates: state.templates);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}


