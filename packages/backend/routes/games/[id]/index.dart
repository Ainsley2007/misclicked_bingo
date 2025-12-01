import 'dart:convert';
import 'dart:io';

import 'package:backend/database.dart';
import 'package:backend/services/game_edit_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getGame(context, id),
    HttpMethod.put => _updateGame(context, id),
    HttpMethod.delete => _deleteGame(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getGame(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    final game = await db.getGameById(id);

    if (game == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Game not found'},
      );
    }

    return Response.json(
      body: {
        'id': game.id,
        'code': game.code,
        'name': game.name,
        'teamSize': game.teamSize,
        'boardSize': game.boardSize,
        'gameMode': game.gameMode,
        'startTime': game.startTime,
        'endTime': game.endTime,
        'createdAt': game.createdAt,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch game'},
    );
  }
}

Future<Response> _updateGame(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();

    final game = await db.getGameById(id);
    if (game == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Game not found'},
      );
    }

    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    final gameEditService = GameEditService(db);
    await gameEditService.updateGame(
      gameId: id,
      name: data['name'] as String?,
    );

    final updatedGame = await db.getGameById(id);
    return Response.json(body: updatedGame?.toJson());
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to update game: $e'},
    );
  }
}

Future<Response> _deleteGame(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    await db.deleteGame(id);

    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to delete game'},
    );
  }
}
