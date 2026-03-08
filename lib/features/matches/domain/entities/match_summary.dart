import 'package:equatable/equatable.dart';

class MatchSummary extends Equatable {
  final String id;
  final String title;
  final String? mapName;
  final bool archived;
  final DateTime updatedAt;

  const MatchSummary({
    required this.id,
    required this.title,
    this.mapName,
    required this.archived,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, mapName, archived, updatedAt];
}



