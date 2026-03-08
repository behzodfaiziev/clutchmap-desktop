import 'package:equatable/equatable.dart';
import '../../domain/entities/benchmark_data.dart';
import '../../domain/entities/meta_alignment.dart';
import '../../domain/entities/meta_trend_point.dart';
import '../../domain/entities/team_snapshot.dart';

abstract class BenchmarkState extends Equatable {
  const BenchmarkState();

  @override
  List<Object?> get props => [];
}

class BenchmarkLoading extends BenchmarkState {}

class BenchmarkLoadedState extends BenchmarkState {
  final BenchmarkData benchmark;
  final MetaAlignment metaAlignment;
  final List<MetaTrendPoint> metaTrends;
  final int trendWindow;
  final List<TeamSnapshot> teamSnapshots;
  final int snapshotWindow;

  const BenchmarkLoadedState({
    required this.benchmark,
    required this.metaAlignment,
    required this.metaTrends,
    this.trendWindow = 30,
    this.teamSnapshots = const [],
    this.snapshotWindow = 30,
  });

  BenchmarkLoadedState copyWith({
    BenchmarkData? benchmark,
    MetaAlignment? metaAlignment,
    List<MetaTrendPoint>? metaTrends,
    int? trendWindow,
    List<TeamSnapshot>? teamSnapshots,
    int? snapshotWindow,
  }) {
    return BenchmarkLoadedState(
      benchmark: benchmark ?? this.benchmark,
      metaAlignment: metaAlignment ?? this.metaAlignment,
      metaTrends: metaTrends ?? this.metaTrends,
      trendWindow: trendWindow ?? this.trendWindow,
      teamSnapshots: teamSnapshots ?? this.teamSnapshots,
      snapshotWindow: snapshotWindow ?? this.snapshotWindow,
    );
  }

  @override
  List<Object?> get props => [
        benchmark,
        metaAlignment,
        metaTrends,
        trendWindow,
        teamSnapshots,
        snapshotWindow,
      ];
}

class BenchmarkError extends BenchmarkState {
  final String message;

  const BenchmarkError(this.message);

  @override
  List<Object?> get props => [message];
}

