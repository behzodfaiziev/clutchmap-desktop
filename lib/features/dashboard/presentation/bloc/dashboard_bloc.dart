import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/backend_error_helper.dart';
import '../../domain/entities/team_insight.dart';
import '../../infrastructure/datasources/dashboard_remote_data_source.dart';
import '../../../capabilities/infrastructure/datasources/capabilities_remote_data_source.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRemoteDataSource dataSource;
  final CapabilitiesRemoteDataSource capabilitiesDataSource;

  DashboardBloc({
    required this.dataSource,
    required this.capabilitiesDataSource,
  }) : super(DashboardLoading()) {
    on<DashboardLoaded>(_onDashboardLoaded);
    on<DashboardInsightsRefreshRequested>(_onInsightsRefresh);
    on<DashboardInsightDismissed>(_onInsightDismissed);
  }

  Future<void> _onDashboardLoaded(
    DashboardLoaded event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final intelligence = await dataSource.getTeamIntelligence(event.teamId);
      final alignment = await dataSource.getMetaAlignment(event.teamId);
      final recentMatches = await dataSource.getRecentMatches();
      List<TeamInsight> insights = [];
      try {
        final insightModels = await dataSource.getTeamInsights(event.teamId);
        insights = insightModels.map((m) => m.toEntity()).toList();
      } catch (_) {
        // Insights optional if endpoint missing or empty team
      }

      TeamCapabilities? capabilities;
      try {
        capabilities = await capabilitiesDataSource.getCapabilities(event.teamId);
      } catch (_) {
        // Capabilities optional
      }

      emit(DashboardLoadedState(
        intelligence: intelligence.toEntity(),
        alignment: alignment.toEntity(),
        recentMatches: recentMatches.map((m) => m.toEntity()).toList(),
        insights: insights,
        capabilities: capabilities,
      ));
    } catch (e) {
      emit(DashboardError(messageFromException(e, fallback: 'Failed to load dashboard')));
    }
  }

  Future<void> _onInsightsRefresh(
    DashboardInsightsRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoadedState) return;
    final current = state as DashboardLoadedState;
    try {
      await dataSource.generateTeamInsights(event.teamId);
      final insightModels = await dataSource.getTeamInsights(event.teamId);
      emit(current.copyWith(
        insights: insightModels.map((m) => m.toEntity()).toList(),
      ));
    } catch (e) {
      emit(DashboardError(messageFromException(e, fallback: 'Failed to refresh insights')));
    }
  }

  Future<void> _onInsightDismissed(
    DashboardInsightDismissed event,
    Emitter<DashboardState> emit,
  ) async {
    if (state is! DashboardLoadedState) return;
    final current = state as DashboardLoadedState;
    try {
      await dataSource.dismissTeamInsight(event.teamId, event.insightId);
      emit(current.copyWith(
        insights: current.insights.where((i) => i.id != event.insightId).toList(),
      ));
    } catch (e) {
      emit(DashboardError(messageFromException(e, fallback: 'Failed to dismiss insight')));
    }
  }
}



