// ============================================================
// RANDOM BOARD GENERATOR - FOR TESTING PURPOSES
// This file can be safely deleted when no longer needed.
// Also delete:
// - packages/backend/routes/games/[id]/generate-random-board.dart
// - Random board button in frontend admin panel
// ============================================================

import 'dart:math';
import 'package:backend/database.dart';
import 'package:uuid/uuid.dart';

class RandomBoardService {
  final AppDatabase _db;
  final Random _random = Random();
  final _uuid = const Uuid();

  RandomBoardService(this._db);

  Future<void> generateRandomBoard(String gameId) async {
    final bosses = await _db.getAllBosses();
    if (bosses.isEmpty) {
      throw Exception('No bosses found in database');
    }

    final existingTiles = await _db.getTilesByGameId(gameId);
    if (existingTiles.isNotEmpty) {
      throw Exception('Game already has tiles. Cannot generate random board.');
    }

    final bossUniqueItems = <String, List<String>>{};
    for (final boss in bosses) {
      final uniqueItems = await _db.getUniqueItemsForBoss(boss.id);
      bossUniqueItems[boss.id] = uniqueItems;
    }

    for (var position = 0; position < 25; position++) {
      final boss = bosses[_random.nextInt(bosses.length)];
      final tileId = _uuid.v4();

      final uniqueItems = bossUniqueItems[boss.id] ?? [];
      final hasUniques = uniqueItems.isNotEmpty;
      final useAnyUnique = hasUniques && _random.nextBool();
      final useSpecificUnique = hasUniques && !useAnyUnique && _random.nextBool();

      String? description;
      if (useAnyUnique) {
        final anyNCount = _random.nextInt(3) + 1;
        description = 'Get $anyNCount unique(s) from ${boss.name}';
        await _db.createBingoTile(
          id: tileId,
          gameId: gameId,
          bossId: boss.id,
          description: description,
          position: position,
          isAnyUnique: true,
          isOrLogic: false,
          anyNCount: anyNCount,
        );
      } else if (useSpecificUnique && uniqueItems.isNotEmpty) {
        final selectedUnique = uniqueItems[_random.nextInt(uniqueItems.length)];
        description = 'Get $selectedUnique from ${boss.name}';
        await _db.createBingoTile(
          id: tileId,
          gameId: gameId,
          bossId: boss.id,
          description: description,
          position: position,
          isAnyUnique: false,
          isOrLogic: false,
          anyNCount: null,
        );
        await _db.createTileUniqueItem(
          tileId: tileId,
          itemName: selectedUnique,
          requiredCount: 1,
        );
      } else {
        description = 'Kill ${boss.name}';
        await _db.createBingoTile(
          id: tileId,
          gameId: gameId,
          bossId: boss.id,
          description: description,
          position: position,
          isAnyUnique: false,
          isOrLogic: false,
          anyNCount: null,
        );
      }
    }
  }
}

