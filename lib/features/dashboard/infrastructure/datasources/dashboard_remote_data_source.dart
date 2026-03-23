import '../../../../core/network/api_client.dart';
import '../models/team_intelligence_model.dart';
import '../models/meta_alignment_model.dart';
import '../models/match_summary_model.dart';
import '../models/team_insight_model.dart';

class DashboardRemoteDataSource {
  final ApiClient api;

  DashboardRemoteDataSource(this.api);

  Future<TeamIntelligenceModel> getTeamIntelligence(String teamId) async {
    final response = await api.get("/teams/$teamId/intelligence");
    final data = response.data as Map<String, dynamic>;
    return TeamIntelligenceModel.fromJson(data);
  }

  Future<MetaAlignmentModel> getMetaAlignment(String teamId) async {
    final response = await api.get("/teams/$teamId/meta-alignment");
    final data = response.data as Map<String, dynamic>;
    return MetaAlignmentModel.fromJson(data);
  }

  Future<List<MatchSummaryModel>> getRecentMatches({int limit = 5}) async {
    final response = await api.get("/match-plans?page=0&size=$limit");
    final data = response.data as Map<String, dynamic>;
    // Handle ApiResponse wrapper
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    final items = responseData['items'] as List<dynamic>? ?? [];
    return items
        .map((item) => MatchSummaryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<TeamInsightModel>> getTeamInsights(
    String teamId, {
    String gameType = 'VALORANT',
    int limit = 10,
  }) async {
    final response = await api.get(
      "/teams/$teamId/insights?gameType=$gameType&limit=$limit",
    );
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    final list = responseData['insights'] as List<dynamic>? ?? [];
    return list
        .map((e) => TeamInsightModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> dismissTeamInsight(String teamId, String insightId) async {
    await api.post("/teams/$teamId/insights/$insightId/dismiss", {});
  }

  Future<int> generateTeamInsights(String teamId, {String gameType = 'VALORANT'}) async {
    final response = await api.post(
      "/teams/$teamId/insights/generate",
      {'gameType': gameType},
    );
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return (responseData['insightsCreated'] as num?)?.toInt() ?? 0;
  }
}

