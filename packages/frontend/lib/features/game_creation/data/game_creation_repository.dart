import 'package:dio/dio.dart';
import 'package:shared_models/shared_models.dart';

class GameCreationRepository {
  final Dio _dio;

  GameCreationRepository(this._dio);

  Future<Game> createGame({
    required String name,
    required int teamSize,
    required bool hasChallenges,
    required int boardSize,
    required List<Map<String, dynamic>> challenges,
    required List<Map<String, dynamic>> tiles,
  }) async {
    final response = await _dio.post(
      '/games',
      data: {
        'name': name,
        'teamSize': teamSize,
        'hasChallenges': hasChallenges,
        'boardSize': boardSize,
        'challenges': challenges,
        'tiles': tiles,
      },
    );

    return Game.fromJson(response.data as Map<String, dynamic>);
  }
}
