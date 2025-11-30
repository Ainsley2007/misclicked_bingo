import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getPublicGames(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getPublicGames(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final games = await db.getAllGames();

    final gamesData = games.map((game) => {
      'id': game.id,
      'code': game.code,
      'name': game.name,
      'teamSize': game.teamSize,
      'boardSize': game.boardSize,
      'createdAt': game.createdAt,
    }).toList();

    return Response.json(body: gamesData);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch games: $e'},
    );
  }
}

