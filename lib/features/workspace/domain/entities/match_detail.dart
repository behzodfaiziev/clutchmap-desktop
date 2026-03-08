import 'package:equatable/equatable.dart';

class MatchDetail extends Equatable {
  final String id;
  final String title;
  final String? mapName;
  final bool archived;

  const MatchDetail({
    required this.id,
    required this.title,
    this.mapName,
    required this.archived,
  });

  @override
  List<Object?> get props => [id, title, mapName, archived];
}



