import 'dart:convert';
import 'dart:io';

import 'package:backend/database.dart';
import 'package:backend/services/teams_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.patch => _updateTeam(context, id),
    HttpMethod.delete => _disbandTeam(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _updateTeam(RequestContext context, String id) async {
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
        body: {'error': 'Only team captain can update the team'},
      );
    }

    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    if (data.containsKey('color')) {
      final teamsService = TeamsService(db);
      await teamsService.updateTeamColor(
        teamId: id,
        color: data['color'] as String,
      );
    }

    final updatedTeam = await db.getTeamById(id);
    return Response.json(body: updatedTeam?.toJson());
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to update team: $e'},
    );
  }
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
