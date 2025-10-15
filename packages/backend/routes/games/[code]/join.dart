import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context, String code) async {
  return switch (context.request.method) {
    HttpMethod.post => _joinGame(context, code),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _joinGame(RequestContext context, String code) async {
  try {
    final userId = context.read<String>();
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final teamName = body['teamName'] as String?;

    if (teamName == null || teamName.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Team name is required'},
      );
    }

    final game = await db.getGameByCode(code);
    if (game == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Game not found'},
      );
    }

    const uuid = Uuid();
    final teamId = uuid.v4();

    await db.createTeam(
      id: teamId,
      gameId: game.id,
      name: teamName,
      captainUserId: userId,
    );

    await db.addUserToTeam(
      userId: userId,
      teamId: teamId,
      gameId: game.id,
      isCaptain: true,
    );

    final team = await db.getTeamById(teamId);
    if (team == null) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': 'Failed to create team'},
      );
    }

    return Response.json(
      statusCode: HttpStatus.ok,
      body: {
        'game': game.toJson(),
        'team': team.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to join game: $e'},
    );
  }
}
