import '../../../../core/network/api_client.dart';
import '../../domain/entities/agent_summary.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/entities/game_map_summary.dart';
import '../../domain/entities/game_type.dart';
import '../../domain/entities/pattern_summary.dart';
import '../../domain/entities/valorant_context_response.dart';

class GameConfigRemoteDataSource {
  final ApiClient api;

  GameConfigRemoteDataSource(this.api);

  Future<GameConfig> getGameConfig(GameType gameType) async {
    final response = await api.get("/games/config/${gameType.name}");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return GameConfig.fromJson(responseData);
  }

  /// GET /games/config/{gameType}/maps — list of maps for a game type.
  Future<List<GameMapSummary>> getMapsByGameType(GameType gameType) async {
    final response = await api.get("/games/config/${gameType.name}/maps");
    final list = response.data is List ? response.data as List<dynamic> : null;
    if (list == null || list.isEmpty) return [];
    return list
        .map((e) => GameMapSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /games/config/{gameType}/patterns — list of strategy patterns for the game. DAY_126.
  Future<List<PatternSummary>> getPatternsByGameType(GameType gameType) async {
    final response = await api.get("/games/config/${gameType.name}/patterns");
    final list = response.data is List ? response.data as List<dynamic> : null;
    if (list == null || list.isEmpty) return [];
    return list
        .map((e) => PatternSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /games/config/VALORANT/agents — Valorant agent catalog. DAY_127.
  Future<List<AgentSummary>> getAgentsByGameType(GameType gameType) async {
    if (gameType != GameType.valorant) return [];
    final response = await api.get("/games/config/${gameType.name}/agents");
    final list = response.data is List ? response.data as List<dynamic> : null;
    if (list == null || list.isEmpty) return [];
    return list
        .map((e) => AgentSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /games/config/VALORANT/prediction-context — synergy, counterGap, retakeScore. DAY_128.
  Future<ValorantContextResponse> postValorantPredictionContext(
    Map<String, dynamic> roundContext,
  ) async {
    final response = await api.post(
      "/games/config/VALORANT/prediction-context",
      roundContext,
    );
    final data = response.data is Map ? response.data as Map<String, dynamic> : null;
    if (data == null) throw Exception("Invalid response");
    return ValorantContextResponse.fromJson(data);
  }
}


