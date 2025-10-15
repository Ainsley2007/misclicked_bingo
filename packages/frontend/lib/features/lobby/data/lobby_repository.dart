import 'package:dio/dio.dart';
import 'package:shared_models/shared_models.dart';

class LobbyRepository {
  LobbyRepository(this._dio);

  final Dio _dio;

  Future<(Game, Team)> joinGame({
    required String code,
    required String teamName,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/games/$code/join',
      data: {'teamName': teamName},
    );

    final gameJson = response.data!['game'] as Map<String, dynamic>;
    final teamJson = response.data!['team'] as Map<String, dynamic>;

    return (Game.fromJson(gameJson), Team.fromJson(teamJson));
  }
}
