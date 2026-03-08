import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../infrastructure/datasources/dashboard_remote_data_source.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRemoteDataSource dataSource;

  DashboardBloc({required this.dataSource}) : super(DashboardLoading()) {
    on<DashboardLoaded>(_onDashboardLoaded);
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

      emit(DashboardLoadedState(
        intelligence: intelligence.toEntity(),
        alignment: alignment.toEntity(),
        recentMatches: recentMatches.map((m) => m.toEntity()).toList(),
      ));
    } on DioException catch (e) {
      emit(DashboardError(
        e.response?.data?['message'] as String? ?? 'Failed to load dashboard',
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}



