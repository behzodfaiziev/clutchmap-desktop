import 'package:equatable/equatable.dart';

class StrategyTemplate extends Equatable {
  final String id;
  final String name;
  final String? mapName;
  final DateTime createdAt;
  final String? category;
  final List<String> tags;

  const StrategyTemplate({
    required this.id,
    required this.name,
    this.mapName,
    required this.createdAt,
    this.category,
    this.tags = const [],
  });

  factory StrategyTemplate.fromJson(Map<String, dynamic> json) {
    return StrategyTemplate(
      id: json['id'] as String,
      name: json['title'] as String? ?? json['name'] as String? ?? '',
      mapName: json['mapName'] as String?,
      createdAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      category: json['category'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [id, name, mapName, createdAt, category, tags];
}


