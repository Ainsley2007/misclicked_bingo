import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:shared_models/shared_models.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getTeamMembers(context, id),
    HttpMethod.post => _addTeamMember(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getTeamMembers(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    final members = await db.getTeamMembers(id);

    final userDtos = members.map((user) {
      return AppUser(
        id: user.id,
        discordId: user.discordId,
        globalName: user.globalName,
        username: user.username,
        email: user.email,
        avatar: user.avatar,
        role: UserRole.values.byName(user.role),
        teamId: user.teamId,
        gameId: user.gameId,
      );
    }).toList();

    return Response.json(
      statusCode: HttpStatus.ok,
      body: userDtos.map((u) => u.toJson()).toList(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to get team members: $e'},
    );
  }
}

Future<Response> _addTeamMember(RequestContext context, String id) async {
  try {
    final currentUserId = context.read<String>();
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final userIdToAdd = body['userId'] as String?;

    if (userIdToAdd == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'userId is required'},
      );
    }

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
        body: {'error': 'Only team captain can add members'},
      );
    }

    // Check if user is already in a team (including being a captain)
    final userToAdd = await db.getUserById(userIdToAdd);
    if (userToAdd == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'User not found'},
      );
    }

    if (userToAdd.teamId != null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'User is already in a team'},
      );
    }

    await db.addUserToTeam(
      userId: userIdToAdd,
      teamId: id,
      gameId: team.gameId,
    );

    return Response.json(
      statusCode: HttpStatus.ok,
      body: {'message': 'Member added successfully'},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to add team member: $e'},
    );
  }
}
