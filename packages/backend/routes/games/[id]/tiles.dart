import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getTiles(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getTiles(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    final tiles = await db.getTilesByGameId(id);

    if (tiles.isEmpty) {
      return Response.json(body: []);
    }

    // Collect all tile IDs for bulk query
    final tileIds = tiles.map((t) => t.id).toList();

    // Fetch all bosses and unique items in parallel (bulk queries)
    final futures = await Future.wait([
      db.getAllBosses(),
      db.getUniqueItemsByTileIds(tileIds),
    ]);

    final allBosses = futures[0] as List<BossesData>;
    final allUniqueItems = futures[1] as List<TileUniqueItem>;

    // Create lookup maps for O(1) access
    final bossMap = {
      for (final boss in allBosses) boss.id: boss,
    };
    final uniqueItemsMap = <String, List<TileUniqueItem>>{};
    for (final item in allUniqueItems) {
      uniqueItemsMap.putIfAbsent(item.tileId, () => []).add(item);
    }

    // Build response by mapping tiles with pre-fetched data
    final tilesWithData = tiles.map((t) {
      final boss = bossMap[t.bossId];
      final uniqueItems = uniqueItemsMap[t.id] ?? [];

      return {
        'id': t.id,
        'gameId': t.gameId,
        'bossId': t.bossId,
        'bossName': boss?.name,
        'bossType': boss?.type,
        'bossIconUrl': boss?.iconUrl,
        'description': t.description,
        'position': t.position,
        'isAnyUnique': t.isAnyUnique,
        'isOrLogic': t.isOrLogic,
        'anyNCount': t.anyNCount,
        'uniqueItems': uniqueItems
            .map(
              (item) => {
                'itemName': item.itemName,
                'requiredCount': item.requiredCount,
              },
            )
            .toList(),
      };
    }).toList();

    return Response.json(body: tilesWithData);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch tiles'},
    );
  }
}
