import 'package:dio/dio.dart';
import 'package:shared_models/shared_models.dart';

class GuestRepository {
  GuestRepository(this._dio);

  final Dio _dio;

  Future<List<Game>> getPublicGames() async {
    final response = await _dio.get<List<dynamic>>('/public/games');
    return response.data!
        .map((json) => Game.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getPublicGameOverview(String gameId) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/public/games/$gameId');
    return response.data!;
  }

  Future<List<TileActivity>> getPublicActivity({
    required String gameId,
    int limit = 50,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/public/games/$gameId/activity',
      queryParameters: {'limit': limit},
    );
    return response.data!
        .map((json) => TileActivity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ProofStats> getPublicStats({required String gameId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/public/games/$gameId/stats',
    );
    return ProofStats.fromJson(response.data!);
  }

  Future<List<TileProof>> getPublicProofs({
    required String gameId,
    required String tileId,
    required String teamId,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/public/games/$gameId/tiles/$tileId/proofs',
      queryParameters: {'teamId': teamId},
    );
    return response.data!
        .map((json) => TileProof.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

