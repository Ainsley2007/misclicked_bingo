import 'package:dio/dio.dart';
import 'package:shared_models/shared_models.dart';

class GamesRepository {
  GamesRepository(this._dio);

  final Dio _dio;

  Future<List<Game>> getGames() async {
    final response = await _dio.get<List<dynamic>>('/games');
    if (response.data == null) return [];
    return response.data!
        .map((json) => Game.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Game> createGame(String name, int teamSize) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/games',
      data: {'name': name, 'teamSize': teamSize},
    );
    if (response.data == null) {
      throw Exception('Failed to create game: null response');
    }
    return Game.fromJson(response.data!);
  }

  Future<void> deleteGame(String gameId) async {
    await _dio.delete('/games/$gameId');
  }

  Future<Game> updateGame({
    required String gameId,
    String? name,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/games/$gameId',
      data: {'name': name},
    );
    return Game.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> getGameOverview(String gameId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/games/$gameId/overview',
    );
    return response.data!;
  }

  Future<void> uncompleteTileForAllTeams({
    required String gameId,
    required String tileId,
    required bool deleteProofs,
  }) async {
    await _dio.post(
      '/games/$gameId/tiles/$tileId/uncomplete-all',
      data: {'deleteProofs': deleteProofs},
    );
  }

  // ============================================================
  // RANDOM BOARD GENERATOR - FOR TESTING PURPOSES
  // Remove this method when no longer needed.
  // ============================================================
  Future<void> generateRandomBoard(String gameId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/games/$gameId/generate-random-board',
    );
    if (response.statusCode != 200) {
      final error = response.data?['error'] ?? 'Unknown error';
      throw Exception(error);
    }
  }
}
