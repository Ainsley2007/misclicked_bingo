import 'package:dio/dio.dart';
import 'package:shared_models/shared_models.dart';

class GameCreationRepository {
  final Dio _dio;

  GameCreationRepository(this._dio);

  Future<Game> createGame({
    required String name,
    required int teamSize,
    required int boardSize,
    required List<GameTileCreation> tiles,
  }) async {
    final response = await _dio.post(
      '/games',
      data: {
        'name': name,
        'teamSize': teamSize,
        'boardSize': boardSize,
        'tiles': tiles.map((tile) => tile.toJson()).toList(),
      },
    );

    return Game.fromJson(response.data as Map<String, dynamic>);
  }
}
