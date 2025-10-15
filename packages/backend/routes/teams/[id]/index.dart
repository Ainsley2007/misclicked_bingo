import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.delete => _disbandTeam(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _disbandTeam(RequestContext context, String id) async {
  try {
    final currentUserId = context.read<String>();
    final db = context.read<AppDatabase>();

    final team = await db.getTeamById(id);
    if (team == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Team not found'},
      );
    }

    if (team.captainUserId != currentUserId) {
      return Response.json(
        statusCode: HttpStatus.forbidden,
        body: {'error': 'Only team captain can disband the team'},
      );
    }

    await db.deleteTeam(id);

    return Response.json(
      statusCode: HttpStatus.ok,
      body: {'message': 'Team disbanded successfully'},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to disband team: $e'},
    );
  }
}
