import 'dart:io';

import 'package:backend/database.dart';
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

    final user = await db.getUserById(userId);
    if (user == null || user.teamId == null) {
      return Response.json(
        statusCode: HttpStatus.forbidden,
        body: {'error': 'User must be part of a team'},
      );
    }

    final currentStatus = await db.getTeamBoardState(
      teamId: user.teamId!,
      tileId: tileId,
    );

    final newStatus = currentStatus == 'completed' ? 'incomplete' : 'completed';

    await db.setTeamBoardState(
      teamId: user.teamId!,
      tileId: tileId,
      status: newStatus,
    );

    return Response.json(
      body: {'status': newStatus},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to toggle tile completion: $e'},
    );
  }
}

