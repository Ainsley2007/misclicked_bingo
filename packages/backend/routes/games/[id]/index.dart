import 'dart:convert';

import 'package:backend/database.dart';
import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/game_service.dart';
import 'package:backend/validators/game_validator.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getGame(context, id),
    HttpMethod.put => _updateGame(context, id),
    HttpMethod.delete => _deleteGame(context, id),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getGame(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    final gameService = GameService(db);
    final game = await gameService.getGameById(id);

    if (game == null) {
      return ResponseHelper.notFound(message: 'Game not found');
    }

    return ResponseHelper.success(data: game);
  } catch (e) {
    return ResponseHelper.internalError();
  }
}

Future<Response> _updateGame(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    final gameService = GameService(db);

    final game = await gameService.getGameById(id);
    if (game == null) {
      return ResponseHelper.notFound(message: 'Game not found');
    }

    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final name = data['name'] as String?;

    final validation = GameValidator.validateUpdateGame(name: name);
    if (!validation.isValid) {
      return ResponseHelper.error(
        message: validation.errorMessage!,
        code: validation.errorCode!,
        details: validation.details,
      );
    }

    final updatedGame = await gameService.updateGame(gameId: id, name: name);
    return ResponseHelper.success(data: updatedGame);
  } catch (e) {
    return ResponseHelper.internalError();
  }
}

Future<Response> _deleteGame(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    final gameService = GameService(db);
    await gameService.deleteGame(id);

    return ResponseHelper.noContent();
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
