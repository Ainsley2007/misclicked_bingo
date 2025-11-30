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
    HttpMethod.post => _uncompleteTileForAllTeams(context, gameId, tileId),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _uncompleteTileForAllTeams(
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
    final deleteProofs = data['deleteProofs'] as bool? ?? false;

    final gameEditService = GameEditService(db);
    await gameEditService.uncompleteTileForAllTeams(
      gameId: gameId,
      tileId: tileId,
      deleteProofs: deleteProofs,
    );

    return Response.json(body: {'success': true});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to uncomplete tile: $e'},
    );
  }
}

