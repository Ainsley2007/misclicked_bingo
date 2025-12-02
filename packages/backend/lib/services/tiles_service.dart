import 'package:backend/database.dart';
import 'package:shared_models/shared_models.dart' as models;

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

  Future<List<models.BingoTile>> getEnrichedTilesForGame({
    required String gameId,
    String? teamId,
  }) async {
    final tiles = await getTilesByGameId(gameId);

    if (tiles.isEmpty) {
      return [];
    }

    final tileIds = tiles.map((t) => t.id).toList();

    final futures = await Future.wait([
      getAllBosses(),
      getUniqueItemsByTileIds(tileIds),
      if (teamId != null)
        getTeamBoardStates(teamId)
      else
        Future.value(<String, String>{}),
      if (teamId != null)
        getProofsByTeam(teamId)
      else
        Future.value(<TileProof>[]),
    ]);

    final allBosses = futures[0] as List<BossesData>;
    final allUniqueItems = futures[1] as List<TileUniqueItem>;
    final completionStates = futures[2] as Map<String, String>;
    final allProofs = futures[3] as List<TileProof>;

    final bossMap = {for (final boss in allBosses) boss.id: boss};
    final uniqueItemsMap = <String, List<TileUniqueItem>>{};
    for (final item in allUniqueItems) {
      uniqueItemsMap.putIfAbsent(item.tileId, () => []).add(item);
    }
    final tilesWithProofs = <String>{};
    for (final proof in allProofs) {
      tilesWithProofs.add(proof.tileId);
    }

    return tiles.map((t) {
      final boss = bossMap[t.bossId];
      final uniqueItems = uniqueItemsMap[t.id] ?? [];
      final isCompleted = completionStates[t.id] == 'completed';
      final hasProofs = tilesWithProofs.contains(t.id);

      return models.BingoTile(
        id: t.id,
        gameId: t.gameId,
        bossId: t.bossId,
        bossName: boss?.name,
        bossType: boss?.type != null
            ? models.BossType.fromString(boss!.type)
            : null,
        bossIconUrl: boss?.iconUrl,
        description: t.description,
        position: t.position,
        isAnyUnique: t.isAnyUnique,
        isOrLogic: t.isOrLogic,
        anyNCount: t.anyNCount,
        points: t.points,
        isCompleted: isCompleted,
        hasProofs: hasProofs,
        uniqueItems: uniqueItems
            .map(
              (item) => models.TileUniqueItem(
                itemName: item.itemName,
                requiredCount: item.requiredCount,
              ),
            )
            .toList(),
      );
    }).toList();
  }
}
