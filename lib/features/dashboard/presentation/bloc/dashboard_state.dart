import 'package:equatable/equatable.dart';
import '../../domain/entities/team_intelligence.dart';
import '../../domain/entities/meta_alignment.dart';
import '../../domain/entities/match_summary.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardLoading extends DashboardState {}

class DashboardLoadedState extends DashboardState {
  final TeamIntelligence intelligence;
  final MetaAlignment alignment;
  final List<MatchSummary> recentMatches;

  const DashboardLoadedState({
    required this.intelligence,
    required this.alignment,
    required this.recentMatches,
  });

  @override
  List<Object?> get props => [intelligence, alignment, recentMatches];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}



