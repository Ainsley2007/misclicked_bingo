import 'dart:developer' as developer;

import 'package:backend/database.dart';
import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/game_service.dart';
import 'package:backend/validators/game_validator.dart';
import 'package:backend/validators/tile_validator.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getGames(context),
    HttpMethod.post => _createGame(context),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getGames(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final gameService = GameService(db);
    final games = await gameService.getAllGames();

    return ResponseHelper.success(data: games);
  } catch (e) {
    return ResponseHelper.internalError();
  }
}

Future<Response> _createGame(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final name = body['name'] as String?;
    final teamSize = body['teamSize'] as int? ?? 5;
    final boardSize = body['boardSize'] as int? ?? 3;
    final gameMode = body['gameMode'] as String? ?? 'blackout';
    final startTimeStr = body['startTime'] as String?;
    final endTimeStr = body['endTime'] as String?;
    final tiles = body['tiles'] as List<dynamic>? ?? [];

    DateTime? startTime;
    if (startTimeStr != null && startTimeStr.isNotEmpty) {
      startTime = DateTime.tryParse(startTimeStr);
    }

    DateTime? endTime;
    if (endTimeStr != null && endTimeStr.isNotEmpty) {
      endTime = DateTime.tryParse(endTimeStr);
    }

    final validation = GameValidator.validateCreateGame(
      name: name,
      teamSize: teamSize,
      boardSize: boardSize,
      gameMode: gameMode,
      startTime: startTime,
      endTime: endTime,
      tiles: tiles,
    );

    if (!validation.isValid) {
      return ResponseHelper.error(
        message: validation.errorMessage!,
        code: validation.errorCode!,
        details: validation.details,
      );
    }

    if (tiles.isNotEmpty) {
      for (final tile in tiles) {
        final t = tile as Map<String, dynamic>;
        final bossId = t['bossId'] as String?;
        final isAnyUnique = t['isAnyUnique'] as bool? ?? false;
        final uniqueItems = t['uniqueItems'] as List<dynamic>?;

        final tileValidation = TileValidator.validateTile(
          bossId: bossId,
          isAnyUnique: isAnyUnique,
          uniqueItems: uniqueItems,
        );

        if (!tileValidation.isValid) {
          return ResponseHelper.error(
            message: tileValidation.errorMessage!,
            code: tileValidation.errorCode!,
            details: tileValidation.details,
          );
        }

        final db = context.read<AppDatabase>();
        final gameService = GameService(db);
        final bossExists = await gameService.verifyBossExists(bossId!);
        if (!bossExists) {
          return ResponseHelper.notFound(
            message: 'Boss not found: $bossId',
          );
        }
      }
    }

    final db = context.read<AppDatabase>();
    final gameService = GameService(db);
    final game = await gameService.createGame(
      name: name!,
      teamSize: teamSize,
      boardSize: boardSize,
      gameMode: gameMode,
      startTime: startTime,
      endTime: endTime,
      tiles: tiles,
    );

    return ResponseHelper.created(data: game);
  } catch (e, stackTrace) {
    developer.log(
      'Failed to create game',
      name: 'games',
      error: e,
      stackTrace: stackTrace,
    );
    return ResponseHelper.internalError();
  }
}
