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

    // Get boss data and unique items for each tile
    final tilesWithData = await Future.wait(
      tiles.map((t) async {
        final boss = await db.getBossById(t.bossId);
        final uniqueItems = await db.getUniqueItemsByTileId(t.id);

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
          'uniqueItems': uniqueItems
              .map(
                (item) => {
                  'itemName': item.itemName,
                  'requiredCount': item.requiredCount,
                },
              )
              .toList(),
        };
      }),
    );

    return Response.json(body: tilesWithData);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch tiles'},
    );
  }
}
