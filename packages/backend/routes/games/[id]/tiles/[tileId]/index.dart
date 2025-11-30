import 'dart:convert';
import 'dart:io';

import 'package:backend/database.dart';
import 'package:backend/services/game_edit_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(
  RequestContext context,
  String gameId,
  String tileId,
) async {
  return switch (context.request.method) {
    HttpMethod.put => _updateTile(context, gameId, tileId),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _updateTile(
  RequestContext context,
  String gameId,
  String tileId,
) async {
  try {
    final userId = context.read<String>();
    final db = context.read<AppDatabase>();

    final user = await db.getUserById(userId);
    if (user == null || user.role != 'admin') {
      return Response.json(
        statusCode: HttpStatus.forbidden,
        body: {'error': 'Admin access required'},
      );
    }

    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    final bossId = data['bossId'] as String?;
    if (bossId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'bossId is required'},
      );
    }

    final uniqueItemsData = data['uniqueItems'] as List<dynamic>?;
    final uniqueItems = uniqueItemsData?.map((item) {
      final itemMap = item as Map<String, dynamic>;
      return TileUniqueItemData(
        itemName: itemMap['itemName'] as String,
        requiredCount: itemMap['requiredCount'] as int? ?? 1,
      );
    }).toList();

    final gameEditService = GameEditService(db);
    await gameEditService.updateTile(
      tileId: tileId,
      bossId: bossId,
      description: data['description'] as String?,
      isAnyUnique: data['isAnyUnique'] as bool? ?? false,
      isOrLogic: data['isOrLogic'] as bool? ?? false,
      anyNCount: data['anyNCount'] as int?,
      uniqueItems: uniqueItems,
    );

    return Response.json(body: {'success': true});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to update tile: $e'},
    );
  }
}

