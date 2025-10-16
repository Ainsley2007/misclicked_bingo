import 'package:dio/dio.dart';
import 'package:shared_models/shared_models.dart';

class GameRepository {
  GameRepository(this._dio);

  final Dio _dio;

  Future<List<AppUser>> getGameUsers(String gameId) async {
    final response = await _dio.get<List<dynamic>>('/games/$gameId/users');
    return response.data!
        .map((json) => AppUser.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<AppUser>> getAllUsers() async {
    final response = await _dio.get<List<dynamic>>('/users');
    return response.data!
        .map((json) => AppUser.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Game> getGame(String gameId) async {
    final response = await _dio.get<Map<String, dynamic>>('/games/$gameId');
    return Game.fromJson(response.data!);
  }

  Future<List<Challenge>> getChallenges(String gameId) async {
    final response = await _dio.get<List<dynamic>>('/games/$gameId/challenges');
    return response.data!
        .map((json) => Challenge.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<BingoTile>> getTiles(String gameId) async {
    final response = await _dio.get<List<dynamic>>('/games/$gameId/tiles');
    return response.data!
        .map((json) => BingoTile.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
