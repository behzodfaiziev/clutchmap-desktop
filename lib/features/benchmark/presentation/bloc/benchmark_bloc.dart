import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/backend_error_helper.dart';
import '../../domain/entities/benchmark_data.dart';
import '../../domain/entities/meta_alignment.dart';
import '../../domain/entities/meta_trend_point.dart';
import '../../domain/entities/team_snapshot.dart';
import '../../infrastructure/datasources/benchmark_remote_data_source.dart';
import 'benchmark_event.dart';
import 'benchmark_state.dart';

class BenchmarkBloc extends Bloc<BenchmarkEvent, BenchmarkState> {
  final BenchmarkRemoteDataSource dataSource;

  BenchmarkBloc({required this.dataSource}) : super(BenchmarkLoading()) {
    on<BenchmarkLoaded>(_onBenchmarkLoaded);
    on<MetaTrendsWindowChanged>(_onMetaTrendsWindowChanged);
    on<SnapshotWindowChanged>(_onSnapshotWindowChanged);
  }

  Future<void> _onBenchmarkLoaded(
    BenchmarkLoaded event,
    Emitter<BenchmarkState> emit,
  ) async {
    emit(BenchmarkLoading());

    try {
      final benchmarkData = await dataSource.getBenchmark(event.teamId);
      final benchmark = BenchmarkData.fromJson(benchmarkData);

      final alignmentData = await dataSource.getMetaAlignment(event.teamId);
      final metaAlignment = MetaAlignment.fromJson(alignmentData);

      final trendsData = await dataSource.getMetaTrends(window: 30);
      final history = trendsData['history'] as List<dynamic>? ?? [];
      final metaTrends = history
          .map((item) => MetaTrendPoint.fromJson(item as Map<String, dynamic>))
          .toList();

      // Load team snapshots
      final snapshotsData = await dataSource.getTeamSnapshots(event.teamId, window: 30);
      final teamSnapshots = snapshotsData
          .map((item) => TeamSnapshot.fromJson(item))
          .toList();

      emit(BenchmarkLoadedState(
        teamId: event.teamId,
        benchmark: benchmark,
        metaAlignment: metaAlignment,
        metaTrends: metaTrends,
        trendWindow: 30,
        teamSnapshots: teamSnapshots,
        snapshotWindow: 30,
      ));
    } catch (e) {
      emit(BenchmarkError(messageFromException(e, fallback: 'Failed to load benchmark')));
    }
  }

  Future<void> _onMetaTrendsWindowChanged(
    MetaTrendsWindowChanged event,
    Emitter<BenchmarkState> emit,
  ) async {
    if (state is BenchmarkLoadedState) {
      final currentState = state as BenchmarkLoadedState;
      try {
        final trendsData = await dataSource.getMetaTrends(window: event.window);
        final history = trendsData['history'] as List<dynamic>? ?? [];
        final metaTrends = history
            .map((item) => MetaTrendPoint.fromJson(item as Map<String, dynamic>))
            .toList();

        emit(currentState.copyWith(
          metaTrends: metaTrends,
          trendWindow: event.window,
        ));
      } catch (e) {
        // Ignore errors - keep current state
      }
    }
  }

  Future<void> _onSnapshotWindowChanged(
    SnapshotWindowChanged event,
    Emitter<BenchmarkState> emit,
  ) async {
    if (state is BenchmarkLoadedState) {
      final currentState = state as BenchmarkLoadedState;
      try {
        final snapshotsData = await dataSource.getTeamSnapshots(currentState.teamId, window: event.window);
        final teamSnapshots = snapshotsData
            .map((item) => TeamSnapshot.fromJson(item))
            .toList();

        emit(currentState.copyWith(
          teamSnapshots: teamSnapshots,
          snapshotWindow: event.window,
        ));
      } catch (e) {
        // Ignore errors - keep current state
      }
    }
  }
}

