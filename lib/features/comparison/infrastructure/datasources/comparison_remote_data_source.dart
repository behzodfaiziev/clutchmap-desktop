import '../../../../core/network/api_client.dart';
import '../../domain/entities/comparison_result.dart';
import '../models/comparison_result_model.dart';

class ComparisonRemoteDataSource {
  final ApiClient api;

  ComparisonRemoteDataSource(this.api);

  Future<ComparisonResult> compareMatches(String matchIdA, String matchIdB) async {
    try {
      final response = await api.get("/match-plans/$matchIdA/compare/$matchIdB");
      final data = response.data as Map<String, dynamic>;
      final responseData = data['data'] as Map<String, dynamic>? ?? data;
      return ComparisonResultModel.fromJson(responseData).toEntity();
    } catch (e) {
      // If backend endpoint doesn't exist, compute diff on frontend
      // For now, return empty result
      return const ComparisonResult(
        overallDelta: 0,
        aggressionDelta: 0,
        structureDelta: 0,
        varietyDelta: 0,
        riskDelta: 0,
        roundDiffs: [],
      );
    }
  }
}

