import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/team/active_team_service.dart';
import '../../infrastructure/datasources/template_remote_data_source.dart';
import '../bloc/template_bloc.dart';
import '../bloc/template_event.dart';
import '../bloc/template_state.dart';
import '../widgets/template_list.dart';
import '../widgets/template_detail_view.dart';

class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  Future<bool>? _hasTeamFuture;

  Future<bool> _ensureTeamThenHasTeam() async {
    final active = getIt<ActiveTeamService>();
    await active.ensureResolved();
    return active.activeTeamId != null && active.activeTeamId!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    _hasTeamFuture ??= _ensureTeamThenHasTeam();
    return FutureBuilder<bool>(
      future: _hasTeamFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || !(snapshot.data ?? false)) {
          return Scaffold(
            appBar: AppBar(title: const Text('Templates')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.hasError
                      ? 'Could not load team. Check backend connection.'
                      : 'No team found. Create or join a team to view templates.',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return BlocProvider(
          create: (context) => TemplateBloc(
            dataSource: getIt<TemplateRemoteDataSource>(),
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
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<TemplateBloc>().add(const TemplatesLoaded());
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
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
      },
    );
  }
}


