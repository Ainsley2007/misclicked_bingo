import 'package:backend/database.dart';

class GameEditService {
  final AppDatabase _db;

  GameEditService(this._db);

  Future<void> updateGame({
    required String gameId,
    String? name,
  }) async {
    if (name != null) {
      await _db.updateGameName(gameId, name);
    }
  }

  Future<void> updateTile({
    required String tileId,
    required String bossId,
    String? description,
    bool? isAnyUnique,
    bool? isOrLogic,
    int? anyNCount,
    List<TileUniqueItemData>? uniqueItems,
  }) async {
    await _db.updateTile(
      tileId: tileId,
      bossId: bossId,
      description: description,
      isAnyUnique: isAnyUnique ?? false,
      isOrLogic: isOrLogic ?? false,
      anyNCount: anyNCount,
    );

    if (uniqueItems != null) {
      await _db.deleteUniqueItemsForTile(tileId);
      for (final item in uniqueItems) {
        await _db.createTileUniqueItem(
          tileId: tileId,
          itemName: item.itemName,
          requiredCount: item.requiredCount,
        );
      }
    }
  }

  Future<void> uncompleteTileForAllTeams({
    required String gameId,
    required String tileId,
    required bool deleteProofs,
  }) async {
    final teams = await _db.getTeamsByGameId(gameId);

    for (final team in teams) {
      await _db.setTeamBoardState(
        teamId: team.id,
        tileId: tileId,
        status: 'incomplete',
        completedByUserId: null,
        completedAt: null,
      );

      if (deleteProofs) {
        await _db.deleteProofsByTileAndTeam(tileId: tileId, teamId: team.id);
      }
    }
  }
}

class TileUniqueItemData {
  final String itemName;
  final int requiredCount;

  TileUniqueItemData({required this.itemName, required this.requiredCount});
}

