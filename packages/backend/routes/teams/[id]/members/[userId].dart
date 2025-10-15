import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
  String userId,
) async {
  return switch (context.request.method) {
    HttpMethod.delete => _removeTeamMember(context, id, userId),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _removeTeamMember(
  RequestContext context,
  String id,
  String userId,
) async {
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
        body: {'error': 'Only team captain can remove members'},
      );
    }

    if (userId == currentUserId) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Captain cannot remove themselves'},
      );
    }

    await db.removeUserFromTeam(userId);

    return Response.json(
      statusCode: HttpStatus.ok,
      body: {'message': 'Member removed successfully'},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to remove team member: $e'},
    );
  }
}
