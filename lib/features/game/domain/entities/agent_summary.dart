/// Agent from GET /games/config/VALORANT/agents. DAY_127.
class AgentSummary {
  final String code;
  final String role;

  const AgentSummary({required this.code, required this.role});

  factory AgentSummary.fromJson(Map<String, dynamic> json) {
    return AgentSummary(
      code: json['code'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }
}
