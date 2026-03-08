import 'package:equatable/equatable.dart';

abstract class BenchmarkEvent extends Equatable {
  const BenchmarkEvent();

  @override
  List<Object?> get props => [];
}

class BenchmarkLoaded extends BenchmarkEvent {
  final String teamId;
  const BenchmarkLoaded(this.teamId);

  @override
  List<Object?> get props => [teamId];
}

class MetaTrendsWindowChanged extends BenchmarkEvent {
  final int window;
  const MetaTrendsWindowChanged(this.window);

  @override
  List<Object?> get props => [window];
}

class SnapshotWindowChanged extends BenchmarkEvent {
  final int window;
  const SnapshotWindowChanged(this.window);

  @override
  List<Object?> get props => [window];
}

