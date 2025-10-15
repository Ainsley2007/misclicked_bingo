import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getTeam(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getTeam(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    final team = await db.getTeamById(id);

    if (team == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Team not found'},
      );
    }

    return Response.json(
      statusCode: HttpStatus.ok,
      body: team.toJson(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to get team: $e'},
    );
  }
}

