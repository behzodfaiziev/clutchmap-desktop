import '../network/api_client.dart';

/// Minimal team summary from GET /teams/me (backend [TeamView]).
class TeamSummary {
  final String id;
  final String name;
  final DateTime? createdAt;

  const TeamSummary({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory TeamSummary.fromJson(Map<String, dynamic> json) {
    DateTime? createdAt;
    final c = json['createdAt'];
    if (c != null) {
      if (c is String) createdAt = DateTime.tryParse(c);
    }
    return TeamSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}

/// Fetches current user's teams from the backend (GET /api/v1/teams/me).
class TeamRemoteDataSource {
  final ApiClient _api;

  TeamRemoteDataSource(this._api);

  /// Returns the list of teams the current user belongs to.
  /// Requires auth; backend returns 401/403 if not authenticated.
  Future<List<TeamSummary>> getMyTeams() async {
    final response = await _api.get('/teams/me');
    final data = response.data;

    List<dynamic> items;
    if (data is List) {
      items = data;
    } else if (data is Map<String, dynamic>) {
      final list = data['data'] ?? data['items'];
      items = list is List ? list : [];
    } else {
      items = [];
    }

    return items
        .map((e) => TeamSummary.fromJson(e as Map<String, dynamic>))
        .where((t) => t.id.isNotEmpty)
        .toList();
  }

  /// Creates a new team. Backend: POST /api/v1/teams with body { name }.
  /// Returns the created team; caller can refresh list and set as selected.
  Future<TeamSummary> createTeam(String name, {String? description}) async {
    final body = <String, dynamic>{'name': name.trim()};
    if (description != null && description.trim().isNotEmpty) {
      body['description'] = description.trim();
    }
    final response = await _api.post('/teams', body);
    final data = response.data;
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    return TeamSummary.fromJson(map);
  }
}
