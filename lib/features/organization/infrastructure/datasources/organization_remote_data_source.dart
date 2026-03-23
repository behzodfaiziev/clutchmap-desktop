import '../../../../core/network/api_client.dart';

class OrgBenchmarkTeamRow {
  final String teamId;
  final String teamName;
  final int tpi;
  final String status;
  final int tpiPercentile;
  final int executionPercentile;
  final int stabilityPercentile;

  const OrgBenchmarkTeamRow({
    required this.teamId,
    required this.teamName,
    required this.tpi,
    required this.status,
    required this.tpiPercentile,
    required this.executionPercentile,
    required this.stabilityPercentile,
  });

  factory OrgBenchmarkTeamRow.fromJson(Map<String, dynamic> json) {
    return OrgBenchmarkTeamRow(
      teamId: json['teamId'] as String? ?? '',
      teamName: json['teamName'] as String? ?? '',
      tpi: (json['tpi'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      tpiPercentile: (json['tpiPercentile'] as num?)?.toInt() ?? 0,
      executionPercentile: (json['executionPercentile'] as num?)?.toInt() ?? 0,
      stabilityPercentile: (json['stabilityPercentile'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrgBenchmarkAverages {
  final int tpi;
  final int execution;
  final int stability;

  const OrgBenchmarkAverages({
    required this.tpi,
    required this.execution,
    required this.stability,
  });

  factory OrgBenchmarkAverages.fromJson(Map<String, dynamic> json) {
    return OrgBenchmarkAverages(
      tpi: (json['tpi'] as num?)?.toInt() ?? 0,
      execution: (json['execution'] as num?)?.toInt() ?? 0,
      stability: (json['stability'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrgBenchmarkModel {
  final List<OrgBenchmarkTeamRow> teams;
  final OrgBenchmarkAverages orgAverages;

  const OrgBenchmarkModel({
    required this.teams,
    required this.orgAverages,
  });

  factory OrgBenchmarkModel.fromJson(Map<String, dynamic> json) {
    final teamsList = json['teams'] as List<dynamic>? ?? [];
    final teams = teamsList
        .map((e) => OrgBenchmarkTeamRow.fromJson(e as Map<String, dynamic>))
        .toList();
    final avgJson = json['orgAverages'] as Map<String, dynamic>? ?? {};
    return OrgBenchmarkModel(
      teams: teams,
      orgAverages: OrgBenchmarkAverages.fromJson(avgJson),
    );
  }
}

class OrganizationRemoteDataSource {
  final ApiClient api;

  OrganizationRemoteDataSource(this.api);

  Future<OrgBenchmarkModel> getBenchmark(String organizationId,
      {String gameType = 'VALORANT'}) async {
    final response = await api.get(
      '/organizations/$organizationId/benchmark?gameType=$gameType',
    );
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return OrgBenchmarkModel.fromJson(responseData);
  }
}
