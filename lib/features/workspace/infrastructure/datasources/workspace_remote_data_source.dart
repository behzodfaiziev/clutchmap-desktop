import '../../../../core/network/api_client.dart';
import '../../../../core/utils/retry_helper.dart';
import '../models/match_detail_model.dart';
import '../models/round_entity_model.dart';
import '../models/tactical_event_model.dart';

class WorkspaceRemoteDataSource {
  final ApiClient api;

  WorkspaceRemoteDataSource(this.api);

  Future<MatchDetailModel> getMatchDetail(String matchId) async {
    return retry(() async {
      final response = await api.get("/match-plans/$matchId");
      final data = response.data as Map<String, dynamic>;
      // Handle ApiResponse wrapper
      final responseData = data['data'] as Map<String, dynamic>? ?? data;
      return MatchDetailModel.fromJson(responseData);
    });
  }

  Future<List<RoundEntityModel>> getRounds(String matchId) async {
    return retry(() async {
      final response = await api.get("/match-plans/$matchId/rounds");
      final data = response.data as Map<String, dynamic>;
      // Handle ApiResponse wrapper
      final responseData = data['data'] as Map<String, dynamic>? ?? data;
      final items = responseData['items'] as List<dynamic>? ?? responseData['rounds'] as List<dynamic>? ?? [];
      return items
          .map((item) => RoundEntityModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> updateRoundNotes(String roundId, String notes) async {
    await api.put(
      "/rounds/$roundId/notes",
      {
        "notes": notes,
      },
    );
  }

  Future<Map<String, dynamic>> acquireLock(String roundId) async {
    final response = await api.post("/match-plans/rounds/$roundId/lock", null);
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<void> releaseLock(String roundId) async {
    await api.delete("/match-plans/rounds/$roundId/lock");
  }

  Future<Map<String, dynamic>> getLockStatus(String roundId) async {
    return retry(() async {
      final response = await api.get("/match-plans/rounds/$roundId/lock");
      final data = response.data as Map<String, dynamic>;
      final responseData = data['data'] as Map<String, dynamic>? ?? data;
      return responseData;
    });
  }

  Future<List<TacticalEventModel>> getTacticalEvents(String roundId) async {
    final response = await api.get("/rounds/$roundId/events");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    final items = responseData['items'] as List<dynamic>? ?? responseData as List<dynamic>? ?? [];
    return items
        .map((item) => TacticalEventModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TacticalEventModel> addTacticalEvent(
    String roundId,
    String eventType, {
    int? timestampSec,
    String? payload,
  }) async {
    final response = await api.post(
      "/rounds/$roundId/events",
      {
        "eventType": eventType,
        ...?timestampSec != null ? {"timestampSec": timestampSec} : null,
        ...?payload != null ? {"payload": payload} : null,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return TacticalEventModel.fromJson(responseData);
  }

  Future<void> removeTacticalEvent(String roundId, String eventId) async {
    await api.delete("/rounds/$roundId/events/$eventId");
  }

  Future<Map<String, dynamic>?> getRoundStrategy(String roundId) async {
    try {
      return await retry(() async {
        final response = await api.get("/match-plans/rounds/$roundId/strategy");
        final data = response.data as Map<String, dynamic>;
        final responseData = data['data'] as Map<String, dynamic>? ?? data;
        return responseData;
      });
    } catch (e) {
      // Strategy might not exist yet
      return null;
    }
  }

  Future<void> updateRoundStrategy(String roundId, String canvasJson) async {
    await api.put(
      "/match-plans/rounds/$roundId/strategy",
      {
        "canvasJson": canvasJson,
      },
    );
  }

  Future<Map<String, dynamic>?> getBuyPlan(String roundId) async {
    try {
      final response = await api.get("/match-plans/rounds/$roundId/buy-plan");
      final data = response.data as Map<String, dynamic>;
      final responseData = data['data'] as Map<String, dynamic>? ?? data;
      return responseData;
    } catch (e) {
      // Buy plan might not exist yet
      return null;
    }
  }

  Future<void> updateBuyPlan(String roundId, String buyJson) async {
    await api.put(
      "/match-plans/rounds/$roundId/buy-plan",
      {
        "buyJson": buyJson,
      },
    );
  }

  Future<void> updateRoundEconomy(String roundId, String economyType) async {
    await api.put(
      "/match-plans/rounds/$roundId/economy",
      {
        "economyType": economyType,
      },
    );
  }

  Future<Map<String, dynamic>> getRoundIntelligence(String roundId) async {
    final response = await api.get("/match-plans/rounds/$roundId/intelligence");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<Map<String, dynamic>> getMatchIntelligence(String matchId) async {
    final response = await api.get("/match-plans/$matchId/intelligence");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<Map<String, dynamic>> getMatchRisk(String matchId) async {
    final response = await api.get("/match-plans/$matchId/risk");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<Map<String, dynamic>> getMatchRobustness(String matchId) async {
    final response = await api.get("/match-plans/$matchId/robustness");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<Map<String, dynamic>?> getMapMatchup(
    String teamId,
    String opponentId,
    String mapId,
  ) async {
    try {
      final response = await api.get("/teams/$teamId/matchup/$opponentId/map/$mapId");
      final data = response.data as Map<String, dynamic>;
      final responseData = data['data'] as Map<String, dynamic>? ?? data;
      return responseData;
    } catch (e) {
      // Matchup might not be available
      return null;
    }
  }

  Future<Map<String, dynamic>> simulateMatchup(
    String teamId,
    String opponentId,
    String? mapId,
  ) async {
    final response = await api.post(
      "/teams/$teamId/simulate-matchup",
      {
        "opponentId": opponentId,
        if (mapId != null) "mapId": mapId,
        "adjustments": {
          "aggressionDelta": 0,
          "structureDelta": 0,
          "varietyDelta": 0,
        },
      },
    );
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<Map<String, dynamic>> optimizeMatchup(
    String teamId,
    String opponentId,
    String? mapId,
    String mode,
  ) async {
    final response = await api.post(
      "/teams/$teamId/optimize-matchup",
      {
        "opponentId": opponentId,
        if (mapId != null) "mapId": mapId,
        "targetAdvantage": "CONTROL_ADVANTAGE",
        "maxRisk": 70,
        "minRobustness": 50,
        "mode": mode,
      },
    );
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<void> applyRecommendation(String recommendationId) async {
    await api.post(
      "/teams/recommendations/$recommendationId/apply",
      {
        "matchPlanId": null, // Will be set by backend if needed
      },
    );
  }

  Future<List<Map<String, dynamic>>> getRecommendations(String teamId) async {
    final response = await api.get("/teams/$teamId/recommendations");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    final items = responseData['items'] as List<dynamic>? ?? [];
    return items.map((item) => item as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> getAdvisorPerformance(String teamId) async {
    final response = await api.get("/teams/$teamId/advisor-performance");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<Map<String, dynamic>?> getRecommendationImpact(String recommendationId) async {
    try {
      // For now, we'll try to get impact from the recommendation application
      // In a real implementation, there would be a dedicated endpoint
      // This is a placeholder - we'll compute from available data
      return null;
    } catch (e) {
      return null;
    }
  }
}

