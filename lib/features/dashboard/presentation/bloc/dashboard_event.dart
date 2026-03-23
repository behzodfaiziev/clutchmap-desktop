import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class DashboardLoaded extends DashboardEvent {
  final String teamId;

  const DashboardLoaded(this.teamId);

  @override
  List<Object?> get props => [teamId];
}

class DashboardInsightsRefreshRequested extends DashboardEvent {
  final String teamId;
  const DashboardInsightsRefreshRequested(this.teamId);
  @override
  List<Object?> get props => [teamId];
}

class DashboardInsightDismissed extends DashboardEvent {
  final String teamId;
  final String insightId;
  const DashboardInsightDismissed({required this.teamId, required this.insightId});
  @override
  List<Object?> get props => [teamId, insightId];
}



