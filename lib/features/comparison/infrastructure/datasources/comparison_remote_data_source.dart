import '../../../../core/network/api_client.dart';
import '../../domain/entities/comparison_result.dart';
import '../models/comparison_result_model.dart';

class ComparisonRemoteDataSource {
  final ApiClient api;

  ComparisonRemoteDataSource(this.api);

  Future<ComparisonResult> compareMatches(String matchIdA, String matchIdB) async {
    final response = await api.get("/match-plans/$matchIdA/compare/$matchIdB");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return ComparisonResultModel.fromJson(responseData).toEntity();
  }
}

