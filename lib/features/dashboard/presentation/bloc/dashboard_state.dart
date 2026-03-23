import 'package:equatable/equatable.dart';
import '../../domain/entities/team_intelligence.dart';
import '../../domain/entities/meta_alignment.dart';
import '../../domain/entities/match_summary.dart';
import '../../domain/entities/team_insight.dart';
import '../../../capabilities/infrastructure/datasources/capabilities_remote_data_source.dart';

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
  final List<TeamInsight> insights;
  final TeamCapabilities? capabilities;

  const DashboardLoadedState({
    required this.intelligence,
    required this.alignment,
    required this.recentMatches,
    this.insights = const [],
    this.capabilities,
  });

  DashboardLoadedState copyWith({
    TeamIntelligence? intelligence,
    MetaAlignment? alignment,
    List<MatchSummary>? recentMatches,
    List<TeamInsight>? insights,
    TeamCapabilities? capabilities,
  }) {
    return DashboardLoadedState(
      intelligence: intelligence ?? this.intelligence,
      alignment: alignment ?? this.alignment,
      recentMatches: recentMatches ?? this.recentMatches,
      insights: insights ?? this.insights,
      capabilities: capabilities ?? this.capabilities,
    );
  }

  @override
  List<Object?> get props => [intelligence, alignment, recentMatches, insights, capabilities];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}



