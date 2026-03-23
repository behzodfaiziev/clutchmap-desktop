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

  /// Archive the current match. Backend: POST /match-plans/{matchPlanId}/archive.
  Future<void> archiveMatch(String matchId) async {
    await api.post("/match-plans/$matchId/archive", null);
  }

  /// Restore (unarchive) the current match. Backend: POST /match-plans/{matchPlanId}/unarchive.
  Future<void> unarchiveMatch(String matchId) async {
    await api.post("/match-plans/$matchId/unarchive", null);
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
      "/match-plans/rounds/$roundId/notes",
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

  /// Renews the current user's lock on a round. Backend: POST /match-plans/rounds/{roundId}/lock/renew.
  Future<Map<String, dynamic>> renewLock(String roundId) async {
    final response = await api.post("/match-plans/rounds/$roundId/lock/renew", null);
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
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

  /// Preview effect of applying a recommendation. Backend: POST /teams/recommendations/{id}/preview-apply.
  Future<Map<String, dynamic>> previewApplyRecommendation(String recommendationId, String matchPlanId) async {
    final response = await api.post(
      "/teams/recommendations/$recommendationId/preview-apply",
      {"matchPlanId": matchPlanId},
    );
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return responseData;
  }

  Future<void> applyRecommendation(String recommendationId, String matchPlanId) async {
    await api.post(
      "/teams/recommendations/$recommendationId/apply",
      {"matchPlanId": matchPlanId},
    );
  }

  /// Submits feedback for a recommendation (e.g. after apply). Backend: POST /teams/recommendations/{id}/feedback.
  Future<void> submitRecommendationFeedback(
    String recommendationId, {
    required bool applied,
    required int rating,
    String notes = '',
  }) async {
    await api.post(
      "/teams/recommendations/$recommendationId/feedback",
      {"applied": applied, "rating": rating, "notes": notes},
    );
  }

  Future<List<Map<String, dynamic>>> getRecommendations(
    String teamId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await api.get(
      "/teams/$teamId/recommendations?page=$page&size=$size",
    );
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

  /// Coach overlay: compact snapshot for match-day second screen.
  Future<OverlayModel> getOverlay(String matchId) async {
    final response = await api.get("/match-plans/$matchId/overlay");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return OverlayModel.fromJson(responseData);
  }
}

class OverlayModel {
  final String matchId;
  final String gameType;
  final String map;
  final int currentRound;
  final String side;
  final OverlayScore score;
  final OverlayActiveArc? activeArc;
  final OverlayRoundPlan roundPlan;
  final List<OverlayAlert> alerts;
  final List<OverlayQuickAction> quickActions;

  const OverlayModel({
    required this.matchId,
    required this.gameType,
    required this.map,
    required this.currentRound,
    required this.side,
    required this.score,
    this.activeArc,
    required this.roundPlan,
    required this.alerts,
    required this.quickActions,
  });

  factory OverlayModel.fromJson(Map<String, dynamic> json) {
    final scoreJson = json['score'] as Map<String, dynamic>? ?? {};
    final roundPlanJson = json['roundPlan'] as Map<String, dynamic>? ?? {};
    final arcJson = json['activeArc'] as Map<String, dynamic>?;
    final alertsList = json['alerts'] as List<dynamic>? ?? [];
    final actionsList = json['quickActions'] as List<dynamic>? ?? [];
    return OverlayModel(
      matchId: json['matchId']?.toString() ?? '',
      gameType: json['gameType'] as String? ?? 'VALORANT',
      map: json['map'] as String? ?? '',
      currentRound: (json['currentRound'] as num?)?.toInt() ?? 1,
      side: json['side'] as String? ?? 'DEFENSE',
      score: OverlayScore.fromJson(scoreJson),
      activeArc: arcJson != null ? OverlayActiveArc.fromJson(arcJson) : null,
      roundPlan: OverlayRoundPlan.fromJson(roundPlanJson),
      alerts: alertsList.map((e) => OverlayAlert.fromJson(e as Map<String, dynamic>)).toList(),
      quickActions: actionsList.map((e) => OverlayQuickAction.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class OverlayScore {
  final int us;
  final int them;

  const OverlayScore({required this.us, required this.them});

  factory OverlayScore.fromJson(Map<String, dynamic> json) {
    return OverlayScore(
      us: (json['us'] as num?)?.toInt() ?? 0,
      them: (json['them'] as num?)?.toInt() ?? 0,
    );
  }
}

class OverlayActiveArc {
  final String id;
  final String name;

  const OverlayActiveArc({required this.id, required this.name});

  factory OverlayActiveArc.fromJson(Map<String, dynamic> json) {
    return OverlayActiveArc(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class OverlayRoundPlan {
  final String pattern;
  final List<String> keyNotes;

  const OverlayRoundPlan({required this.pattern, required this.keyNotes});

  factory OverlayRoundPlan.fromJson(Map<String, dynamic> json) {
    final notes = json['keyNotes'] as List<dynamic>? ?? [];
    return OverlayRoundPlan(
      pattern: json['pattern'] as String? ?? 'DEFAULT',
      keyNotes: notes.map((e) => e.toString()).toList(),
    );
  }
}

class OverlayAlert {
  final String type;
  final int severity;
  final String text;

  const OverlayAlert({required this.type, required this.severity, required this.text});

  factory OverlayAlert.fromJson(Map<String, dynamic> json) {
    return OverlayAlert(
      type: json['type'] as String? ?? 'INFO',
      severity: (json['severity'] as num?)?.toInt() ?? 50,
      text: json['text'] as String? ?? '',
    );
  }
}

class OverlayQuickAction {
  final String action;
  final String label;
  final String? targetArcId;

  const OverlayQuickAction({required this.action, required this.label, this.targetArcId});

  factory OverlayQuickAction.fromJson(Map<String, dynamic> json) {
    return OverlayQuickAction(
      action: json['action'] as String? ?? '',
      label: json['label'] as String? ?? '',
      targetArcId: json['targetArcId']?.toString(),
    );
  }
}

