import 'package:backend/database.dart';

class TileCompletionResult {
  TileCompletionResult.success(this.status) : success = true, error = null;
  TileCompletionResult.failure(this.error) : success = false, status = null;
  final bool success;
  final String? error;
  final String? status;
}

class TilesService {
  TilesService(this._db);
  final AppDatabase _db;

  Future<TileCompletionResult> completeTile({
    required String tileId,
    required String teamId,
    required String userId,
  }) async {
    final proofCount = await _db.getProofCountByTileAndTeam(
      tileId: tileId,
      teamId: teamId,
    );

    if (proofCount < 1) {
      return TileCompletionResult.failure(
        'At least 1 proof screenshot is required to complete a tile',
      );
    }

    await _db.setTeamBoardState(
      teamId: teamId,
      tileId: tileId,
      status: 'completed',
      completedByUserId: userId,
      completedAt: DateTime.now(),
    );

    return TileCompletionResult.success('completed');
  }

  Future<TileCompletionResult> uncompleteTile({
    required String tileId,
    required String teamId,
  }) async {
    await _db.setTeamBoardState(
      teamId: teamId,
      tileId: tileId,
      status: 'incomplete',
    );

    return TileCompletionResult.success('incomplete');
  }

  Future<TileCompletionResult> toggleTileCompletion({
    required String tileId,
    required String teamId,
    required String userId,
  }) async {
    final currentState = await _db.getTeamBoardStateData(
      teamId: teamId,
      tileId: tileId,
    );

    if (currentState?.status == 'completed') {
      return uncompleteTile(tileId: tileId, teamId: teamId);
    } else {
      return completeTile(tileId: tileId, teamId: teamId, userId: userId);
    }
  }

  Future<List<BingoTile>> getTilesByGameId(String gameId) async {
    return _db.getTilesByGameId(gameId);
  }

  Future<String?> getTeamBoardState({
    required String teamId,
    required String tileId,
  }) async {
    return _db.getTeamBoardState(teamId: teamId, tileId: tileId);
  }

  Future<Map<String, String>> getTeamBoardStates(String teamId) async {
    return _db.getTeamBoardStates(teamId);
  }

  Future<List<TileProof>> getProofsByTeam(String teamId) async {
    return _db.getProofsByTeam(teamId);
  }

  Future<List<TileProof>> getProofsByTileAndTeam({
    required String tileId,
    required String teamId,
  }) async {
    return _db.getProofsByTileAndTeam(tileId: tileId, teamId: teamId);
  }

  Future<List<BossesData>> getAllBosses() async {
    return _db.getAllBosses();
  }

  Future<List<TileUniqueItem>> getUniqueItemsByTileIds(
    List<String> tileIds,
  ) async {
    return _db.getUniqueItemsByTileIds(tileIds);
  }

  Future<List<String>> getBossUniqueItemNames(String bossId) async {
    final items = await _db.getUniqueItemsByBossId(bossId);
    return items.map((item) => item.itemName).toList();
  }
}
