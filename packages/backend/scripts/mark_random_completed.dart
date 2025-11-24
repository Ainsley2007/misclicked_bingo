import 'dart:math';
import 'package:backend/db.dart';

Future<void> main() async {
  print('🎯 Marking random tiles as completed for Winners delight...\n');

  final db = Db.instance;

  // Find the Winners delight team
  final query = db.select(db.teams)
    ..where((t) => t.name.equals('Winners delight'));
  final winnersTeam = await query.getSingleOrNull();

  if (winnersTeam == null) {
    print('❌ Winners delight team not found.');
    return;
  }

  print('📋 Found team: ${winnersTeam.name} (${winnersTeam.id})');

  // Get all tiles for this game
  final tiles = await db.getTilesByGameId(winnersTeam.gameId);
  print('🎲 Found ${tiles.length} tiles for the game\n');

  if (tiles.isEmpty) {
    print('❌ No tiles found for this game.');
    return;
  }

  // Mark random 30-40% of tiles as completed
  final random = Random();
  final completionRate = 0.3 + random.nextDouble() * 0.1; // 30-40%
  final tilesToComplete = (tiles.length * completionRate).round();

  print('✨ Marking $tilesToComplete tiles as completed...\n');

  // Shuffle tiles and take the first N
  final shuffledTiles = List<dynamic>.from(tiles)..shuffle(random);
  final tilesToMark = shuffledTiles.take(tilesToComplete);

  for (final tile in tilesToMark) {
    await db.setTeamBoardState(
      teamId: winnersTeam.id,
      tileId: tile.id as String,
      status: 'completed',
    );
    print('✅ Marked tile at position ${tile.position} as completed');
  }

  print(
    '\n🎉 Successfully marked $tilesToComplete tiles as completed for Winners delight!',
  );
}
