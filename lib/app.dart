import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/logging/app_logger.dart';
import 'core/routing/app_router.dart';
import 'core/shortcuts/app_shortcuts.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_shell.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/settings/infrastructure/datasources/settings_local_data_source.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';

class App extends StatelessWidget {
  const App({super.key});

  static void setupErrorHandling() {
    final logger = getIt<AppLogger>();

    FlutterError.onError = (details) {
      logger.error("FlutterError: ${details.exception}", details.exception, details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      logger.error("Uncaught error", error, stack);
      return true;
    };
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(authRepository: getIt<AuthRepository>())..add(AppStarted()),
        ),
        BlocProvider(
          create: (_) =>
              SettingsBloc(localDataSource: SettingsLocalDataSource())..add(SettingsLoaded()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, settingsState) {
              return MaterialApp.router(
                title: 'ClutchMap',
                theme: (settingsState.settings.darkMode) ? AppTheme.darkTheme : AppTheme.lightTheme,
                routerConfig: createRouter(context),
                builder: (context, child) {
                  if (child == null) return const SizedBox.shrink();
                  return BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      if (authState is AuthUnauthenticated) {
                        return child;
                      }
                      final path = GoRouterState.of(context).uri.path;
                      final showRightPanel = path != '/' && path != '/team-select';
                      return AppShortcuts(
                        child: AppShell(
                          child: child,
                          showRightPanel: showRightPanel,
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
