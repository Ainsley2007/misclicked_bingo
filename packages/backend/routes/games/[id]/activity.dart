import 'dart:io';

import 'package:backend/services/activity_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getActivity(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getActivity(RequestContext context, String gameId) async {
  try {
    final activityService = context.read<ActivityService>();

    final limitParam = context.request.uri.queryParameters['limit'];
    final limit = limitParam != null ? int.tryParse(limitParam) ?? 50 : 50;

    final activities = await activityService.getRecentActivity(
      gameId: gameId,
      limit: limit,
    );

    return Response.json(body: activities.map((a) => a.toJson()).toList());
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch activity: $e'},
    );
  }
}

