import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/di/injection.dart';
import '../../core/team/active_team_service.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/team_selection/presentation/pages/team_selection_page.dart';
import '../../features/dashboard/presentation/pages/test_connectivity_page.dart';
import '../../features/matches/presentation/pages/matches_page.dart';
import '../../features/workspace/presentation/pages/match_workspace_page.dart';
import '../../features/benchmark/presentation/pages/benchmark_page.dart';
import '../../features/opponents/presentation/pages/opponents_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/templates/presentation/pages/templates_page.dart';
import '../../features/comparison/presentation/pages/comparison_page.dart';
import '../../features/organization/presentation/pages/org_benchmark_page.dart';
import '../../features/workspace/presentation/pages/overlay_page.dart';
import '../../features/team_management/presentation/pages/team_management_page.dart';

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
        return '/team-select';
      }

      if (authState is AuthAuthenticated &&
          state.uri.path == '/') {
        final activeTeamId = getIt<ActiveTeamService>().activeTeamId;
        if (activeTeamId == null || activeTeamId.isEmpty) {
          return '/team-select';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/team-select',
        builder: (context, state) => const TeamSelectionPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: '/matches',
        builder: (context, state) {
          final opponentId = state.uri.queryParameters['opponentId'];
          return MatchesPage(opponentId: opponentId);
        },
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
        path: '/benchmark',
        builder: (context, state) => const BenchmarkPage(),
      ),
      GoRoute(
        path: '/opponents',
        builder: (context, state) => const OpponentsPage(),
      ),
      GoRoute(
        path: '/teams',
        builder: (context, state) => const TeamManagementPage(),
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
      GoRoute(
        path: '/org-benchmark',
        builder: (context, state) {
          final orgId = state.uri.queryParameters['orgId'];
          return OrgBenchmarkPage(orgIdFromRoute: orgId);
        },
      ),
      GoRoute(
        path: '/overlay/:matchId',
        builder: (context, state) {
          final matchId = state.pathParameters['matchId'] ?? '';
          return OverlayPage(matchId: matchId);
        },
      ),
    ],
  );
}

