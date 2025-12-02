import 'dart:math';
import 'package:backend/database.dart';
import 'package:uuid/uuid.dart';

class GameService {
  final AppDatabase _db;

  GameService(this._db);

  Future<List<dynamic>> getAllGames() async {
    final games = await _db.getAllGames();
    return games
        .map(
          (g) => {
            'id': g.id,
            'code': g.code,
            'name': g.name,
            'teamSize': g.teamSize,
            'boardSize': g.boardSize,
            'gameMode': g.gameMode,
            'startTime': g.startTime,
            'endTime': g.endTime,
            'createdAt': g.createdAt,
          },
        )
        .toList();
  }

  Future<Map<String, dynamic>?> getGameById(String id) async {
    final game = await _db.getGameById(id);
    if (game == null) return null;

    return {
      'id': game.id,
      'code': game.code,
      'name': game.name,
      'teamSize': game.teamSize,
      'boardSize': game.boardSize,
      'gameMode': game.gameMode,
      'startTime': game.startTime,
      'endTime': game.endTime,
      'createdAt': game.createdAt,
    };
  }

  Future<Map<String, dynamic>> createGame({
    required String name,
    required int teamSize,
    required int boardSize,
    required String gameMode,
    DateTime? startTime,
    DateTime? endTime,
    List<dynamic>? tiles,
  }) async {
    final id = const Uuid().v4();
    final code = _generateGameCode();
    final now = DateTime.now();

    await _db.createGame(
      id: id,
      code: code,
      name: name.trim(),
      teamSize: teamSize,
      boardSize: boardSize,
      gameMode: gameMode,
      startTime: startTime,
      endTime: endTime,
      createdAt: now,
    );

    if (tiles != null && tiles.isNotEmpty) {
      await _createTilesForGame(
        gameId: id,
        tiles: tiles,
        gameMode: gameMode,
      );
    }

    return {
      'id': id,
      'code': code,
      'name': name.trim(),
      'teamSize': teamSize,
      'boardSize': boardSize,
      'gameMode': gameMode,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'createdAt': now.toIso8601String(),
    };
  }

  Future<void> _createTilesForGame({
    required String gameId,
    required List<dynamic> tiles,
    required String gameMode,
  }) async {
    for (var i = 0; i < tiles.length; i++) {
      final t = tiles[i] as Map<String, dynamic>;
      final bossId = t['bossId'] as String;
      final description = t['description'] as String?;
      final uniqueItems = t['uniqueItems'] as List<dynamic>?;
      final tilePoints = (t['points'] as num?)?.toInt() ?? 0;
      final isAnyUnique = t['isAnyUnique'] as bool? ?? false;
      final isOrLogic = t['isOrLogic'] as bool? ?? false;
      final anyNCount = (t['anyNCount'] as num?)?.toInt();

      final tileId = const Uuid().v4();
      await _db.createBingoTile(
        id: tileId,
        gameId: gameId,
        bossId: bossId,
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        position: i,
        isAnyUnique: isAnyUnique,
        isOrLogic: isOrLogic,
        anyNCount: anyNCount,
        points: tilePoints,
      );

      if (!isAnyUnique && uniqueItems != null) {
        for (final item in uniqueItems) {
          final itemData = item as Map<String, dynamic>;
          final itemName = itemData['itemName'] as String?;
          final requiredCount =
              (itemData['requiredCount'] as num?)?.toInt() ?? 1;

          if (itemName == null || itemName.trim().isEmpty) {
            continue;
          }

          await _db.createTileUniqueItem(
            tileId: tileId,
            itemName: itemName.trim(),
            requiredCount: requiredCount,
          );
        }
      }
    }
  }

  Future<Map<String, dynamic>?> updateGame({
    required String gameId,
    String? name,
  }) async {
    if (name != null) {
      await _db.updateGameName(gameId, name);
    }

    return getGameById(gameId);
  }

  Future<void> deleteGame(String id) async {
    await _db.deleteGame(id);
  }

  Future<bool> verifyBossExists(String bossId) async {
    final boss = await _db.getBossById(bossId);
    return boss != null;
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

  String _generateGameCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}

class TileUniqueItemData {
  final String itemName;
  final int requiredCount;

  TileUniqueItemData({required this.itemName, required this.requiredCount});
}
