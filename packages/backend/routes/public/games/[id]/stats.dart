import 'dart:io';

import 'package:backend/database.dart';
import 'package:backend/services/activity_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getPublicStats(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getPublicStats(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    final game = await db.getGameById(id);
    if (game == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Game not found'},
      );
    }

    final activityService = ActivityService(db);
    final stats = await activityService.getStats(gameId: id);

    return Response.json(body: stats.toJson());
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch stats: $e'},
    );
  }
}

