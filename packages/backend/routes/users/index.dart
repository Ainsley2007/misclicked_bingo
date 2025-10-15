import 'dart:io';
import 'dart:developer' as developer;

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getUsers(context),
    HttpMethod.delete => _deleteUser(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getUsers(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final users = await db.getAllUsers();

    return Response.json(
      body: users
          .map(
            (u) => {
              'id': u.id,
              'discordId': u.discordId,
              'globalName': u.globalName,
              'username': u.username,
              'email': u.email,
              'avatar': u.avatar,
              'role': u.role,
              'teamId': u.teamId,
              'gameId': u.gameId,
            },
          )
          .toList(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch users'},
    );
  }
}

Future<Response> _deleteUser(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final userId = body['userId'] as String?;

    if (userId == null || userId.trim().isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'User ID is required'},
      );
    }

    final db = context.read<AppDatabase>();
    await db.deleteUser(userId);

    return Response(statusCode: HttpStatus.noContent);
  } catch (e, stackTrace) {
    developer.log(
      'Failed to delete user',
      name: 'users',
      error: e,
      stackTrace: stackTrace,
    );
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to delete user'},
    );
  }
}
