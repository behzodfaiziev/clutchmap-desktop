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



