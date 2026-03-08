import '../../../../core/network/api_client.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/entities/game_type.dart';

class GameConfigRemoteDataSource {
  final ApiClient api;

  GameConfigRemoteDataSource(this.api);

  Future<GameConfig> getGameConfig(GameType gameType) async {
    final response = await api.get("/games/config/${gameType.name}");
    final data = response.data as Map<String, dynamic>;
    final responseData = data['data'] as Map<String, dynamic>? ?? data;
    return GameConfig.fromJson(responseData);
  }
}


