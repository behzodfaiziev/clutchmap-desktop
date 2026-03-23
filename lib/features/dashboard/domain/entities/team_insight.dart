import 'package:equatable/equatable.dart';

class TeamInsight extends Equatable {
  final String id;
  final String category;
  final int severity;
  final String headline;
  final String description;
  final String status;
  final DateTime createdAt;

  const TeamInsight({
    required this.id,
    required this.category,
    required this.severity,
    required this.headline,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, category, severity, headline, description, status, createdAt];
}
