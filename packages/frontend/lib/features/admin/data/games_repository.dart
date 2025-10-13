import 'package:dio/dio.dart';
import 'package:shared_models/shared_models.dart';

class GamesRepository {
  GamesRepository(this._dio);

  final Dio _dio;

  Future<List<Game>> getGames() async {
    final response = await _dio.get<List<dynamic>>('/games');
    if (response.data == null) return [];
    return response.data!.map((json) => Game.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Game> createGame(String name) async {
    final response = await _dio.post<Map<String, dynamic>>('/games', data: {'name': name});
    if (response.data == null) {
      throw Exception('Failed to create game: null response');
    }
    return Game.fromJson(response.data!);
  }

  Future<void> deleteGame(String gameId) async {
    await _dio.delete('/games/$gameId');
  }
}
