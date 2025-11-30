import 'dart:io';

import 'package:backend/database.dart';
import 'package:backend/services/activity_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getPublicActivity(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getPublicActivity(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    final game = await db.getGameById(id);
    if (game == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Game not found'},
      );
    }

    final limitParam = context.request.uri.queryParameters['limit'];
    final limit = limitParam != null ? int.tryParse(limitParam) ?? 50 : 50;

    final activityService = ActivityService(db);
    final activities = await activityService.getRecentActivity(
      gameId: id,
      limit: limit,
    );

    return Response.json(
      body: activities.map((a) => a.toJson()).toList(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch activity: $e'},
    );
  }
}

