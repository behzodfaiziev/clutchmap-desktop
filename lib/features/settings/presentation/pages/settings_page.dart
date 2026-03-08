import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../infrastructure/datasources/settings_local_data_source.dart';
import '../../infrastructure/datasources/system_remote_data_source.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/account_section.dart';
import '../widgets/appearance_section.dart';
import '../widgets/system_section.dart';
import '../widgets/dev_tools_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? appVersion;
  Map<String, dynamic>? capabilities;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadCapabilities();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = "${info.version}+${info.buildNumber}";
    });
  }

  Future<void> _loadCapabilities() async {
    try {
      final dataSource = SystemRemoteDataSource(getIt<ApiClient>());
      final caps = await dataSource.getCapabilities();
      setState(() {
        capabilities = caps;
      });
    } catch (e) {
      // Ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = SettingsLocalDataSource();
        final bloc = SettingsBloc(
          localDataSource: dataSource,
        );
        bloc.add(SettingsLoaded());
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AccountSection(),
            const SizedBox(height: 16),
            const AppearanceSection(),
            const SizedBox(height: 16),
            SystemSection(
              appVersion: appVersion,
              backendVersion: capabilities?['version'] as String?,
            ),
            const SizedBox(height: 16),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Developer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Dev Mode'),
                        subtitle: const Text('Show developer tools'),
                        value: state.settings.devMode,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(DevModeToggled(value));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                if (state.settings.devMode) {
                  return DevToolsSection(
                    capabilities: capabilities,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

