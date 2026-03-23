import '../../../../core/network/api_client.dart';

class QuotaUsage {
  final int used;
  final int limit;

  const QuotaUsage({required this.used, required this.limit});

  factory QuotaUsage.fromJson(Map<String, dynamic> json) {
    return QuotaUsage(
      used: (json['used'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? 0,
    );
  }
}

class TeamCapabilities {
  final String planCode;
  final String planName;
  final Map<String, bool> features;
  final Map<String, QuotaUsage> quotas;

  const TeamCapabilities({
    required this.planCode,
    required this.planName,
    required this.features,
    required this.quotas,
  });

  bool get isAiCoachAllowed => features['AI_COACH'] ?? false;
  bool get isVectorSearchAllowed => features['VECTOR_SEARCH'] ?? false;
  bool get isSeasonModeAllowed => features['SEASON_MODE'] ?? false;

  factory TeamCapabilities.fromJson(Map<String, dynamic> json) {
    final featuresRaw = json['features'] as Map<String, dynamic>? ?? {};
    final features = featuresRaw.map((k, v) => MapEntry(k, v == true));

    final quotasRaw = json['quotas'] as Map<String, dynamic>? ?? {};
    final quotas = quotasRaw.map((k, v) {
      final q = v as Map<String, dynamic>?;
      return MapEntry(k, q != null ? QuotaUsage.fromJson(q) : const QuotaUsage(used: 0, limit: 0));
    });

    return TeamCapabilities(
      planCode: json['planCode'] as String? ?? 'FREE',
      planName: json['planName'] as String? ?? 'Free',
      features: features,
      quotas: quotas,
    );
  }
}

class CapabilitiesRemoteDataSource {
  final ApiClient api;

  CapabilitiesRemoteDataSource(this.api);

  Future<TeamCapabilities> getCapabilities(String teamId) async {
    final response = await api.get('/teams/$teamId/capabilities');
    final data = response.data as Map<String, dynamic>;
    return TeamCapabilities.fromJson(data);
  }
}
