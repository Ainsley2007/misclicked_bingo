import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:shared_models/shared_models.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getGameUsers(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getGameUsers(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    final users = await db.getUsersInGame(id);

    final userDtos = users.map((user) {
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
      body: {'error': 'Failed to get game users: $e'},
    );
  }
}
