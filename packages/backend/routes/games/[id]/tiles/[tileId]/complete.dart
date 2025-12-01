import 'dart:io';

import 'package:backend/database.dart';
import 'package:backend/services/tiles_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(
  RequestContext context,
  String gameId,
  String tileId,
) async {
  return switch (context.request.method) {
    HttpMethod.put => _toggleTileCompletion(context, gameId, tileId),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _toggleTileCompletion(
  RequestContext context,
  String gameId,
  String tileId,
) async {
  try {
    final userId = context.read<String>();
    final db = context.read<AppDatabase>();
    final tilesService = context.read<TilesService>();

    final user = await db.getUserById(userId);
    if (user == null || user.teamId == null) {
      return Response.json(
        statusCode: HttpStatus.forbidden,
        body: {'error': 'User must be part of a team'},
      );
    }

    // Check if game has started
    final game = await db.getGameById(gameId);
    if (game == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Game not found'},
      );
    }

    if (game.startTime != null) {
      final startTime = DateTime.tryParse(game.startTime!);
      if (startTime != null && DateTime.now().isBefore(startTime)) {
        return Response.json(
          statusCode: HttpStatus.forbidden,
          body: {
            'error': 'Game has not started yet',
            'code': 'GAME_NOT_STARTED',
            'startTime': game.startTime,
          },
        );
      }
    }

    // Check if game has ended (optional: prevent completion after end time)
    if (game.endTime != null) {
      final endTime = DateTime.tryParse(game.endTime!);
      if (endTime != null && DateTime.now().isAfter(endTime)) {
        return Response.json(
          statusCode: HttpStatus.forbidden,
          body: {
            'error': 'Game has ended',
            'code': 'GAME_ENDED',
            'endTime': game.endTime,
          },
        );
      }
    }

    // Debug logging
    print('[COMPLETE] User: $userId, TeamId: ${user.teamId}, TileId: $tileId');
    
    final result = await tilesService.toggleTileCompletion(
      tileId: tileId,
      teamId: user.teamId!,
      userId: userId,
    );

    print('[COMPLETE] Result: success=${result.success}, status=${result.status}, error=${result.error}');

    if (!result.success) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': result.error},
      );
    }

    return Response.json(body: {'status': result.status});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to toggle tile completion: $e'},
    );
  }
}
