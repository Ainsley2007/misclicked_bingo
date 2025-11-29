import 'dart:io';

import 'package:backend/services/activity_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getStats(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getStats(RequestContext context, String gameId) async {
  try {
    final activityService = context.read<ActivityService>();

    final stats = await activityService.getStats(gameId: gameId);

    return Response.json(body: stats.toJson());
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch stats: $e'},
    );
  }
}

