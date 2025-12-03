import 'package:dio/dio.dart';
import 'package:frontend/api/games_api.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:shared_models/shared_models.dart';

class GamesRepository {
  GamesRepository(this._api);

  final GamesApi _api;

  Future<List<Game>> getGames() async {
    try {
      return await _api.getGames();
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<Game> getGame(String gameId) async {
    try {
      return await _api.getGame(gameId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<Game> createGame({
    required String name,
    required int teamSize,
    required int boardSize,
    required GameMode gameMode,
    DateTime? startTime,
    DateTime? endTime,
    required List<GameTileCreation> tiles,
  }) async {
    try {
      return await _api.createGame({
        'name': name,
        'teamSize': teamSize,
        'boardSize': boardSize,
        'gameMode': gameMode.value,
        if (startTime != null) 'startTime': startTime.toUtc().toIso8601String(),
        if (endTime != null) 'endTime': endTime.toUtc().toIso8601String(),
        'tiles': tiles.map((tile) => tile.toJson()).toList(),
      });
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<Game> updateGame({required String gameId, String? name}) async {
    try {
      return await _api.updateGame(gameId, {'name': name});
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<void> deleteGame(String gameId) async {
    try {
      await _api.deleteGame(gameId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<(Game, Team)> joinGame({required String code, required String teamName}) async {
    try {
      final response = await _api.joinGame(code, {'teamName': teamName});
      return (response.game, response.team);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<List<BingoTile>> getTiles(String gameId) async {
    try {
      return await _api.getTiles(gameId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<GameOverview> getOverview(String gameId) async {
    try {
      return await _api.getOverview(gameId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<List<AppUser>> getGameUsers(String gameId) async {
    try {
      return await _api.getGameUsers(gameId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<TileCompletionResponse> toggleTileCompletion({required String gameId, required String tileId}) async {
    try {
      return await _api.toggleTileCompletion(gameId, tileId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<void> uncompleteTileForAllTeams({required String gameId, required String tileId, required bool deleteProofs}) async {
    try {
      await _api.uncompleteTileForAllTeams(gameId, tileId, {'deleteProofs': deleteProofs});
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<List<TileActivity>> getActivity(String gameId, {int? limit}) async {
    try {
      return await _api.getActivity(gameId, limit);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<ProofStats> getStats(String gameId) async {
    try {
      return await _api.getStats(gameId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<List<Game>> getPublicGames() async {
    try {
      return await _api.getPublicGames();
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<GameOverview> getPublicOverview(String gameId) async {
    try {
      return await _api.getPublicOverview(gameId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<List<TileActivity>> getPublicActivity(String gameId, {int? limit}) async {
    try {
      return await _api.getPublicActivity(gameId, limit);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<ProofStats> getPublicStats(String gameId) async {
    try {
      return await _api.getPublicStats(gameId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }
}
