import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/test_connectivity_page.dart';
import '../../features/matches/presentation/pages/matches_page.dart';
import '../../features/workspace/presentation/pages/match_workspace_page.dart';
import '../../features/benchmark/presentation/pages/benchmark_page.dart';
import '../../features/opponents/presentation/pages/opponents_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/templates/presentation/pages/templates_page.dart';
import '../../features/comparison/presentation/pages/comparison_page.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    redirect: (context, state) {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;

      if (authState is AuthUnauthenticated &&
          state.uri.path != '/login') {
        return '/login';
      }

      if (authState is AuthAuthenticated &&
          state.uri.path == '/login') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/matches',
        builder: (context, state) => const MatchesPage(),
      ),
      GoRoute(
        path: '/test',
        builder: (context, state) => const TestConnectivityPage(),
      ),
      GoRoute(
        path: '/match/:id',
        builder: (context, state) =>
          MatchWorkspacePage(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/benchmark/:teamId',
        builder: (context, state) =>
          BenchmarkPage(teamId: state.pathParameters['teamId']!),
      ),
      GoRoute(
        path: '/opponents/:teamId',
        builder: (context, state) =>
          OpponentsPage(teamId: state.pathParameters['teamId']!),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/templates',
        builder: (context, state) => const TemplatesPage(),
      ),
      GoRoute(
        path: '/comparison',
        builder: (context, state) => const ComparisonPage(),
      ),
    ],
  );
}

