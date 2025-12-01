import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getGames(context),
    HttpMethod.post => _createGame(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getGames(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final games = await db.getAllGames();

    return Response.json(
      body: games
          .map(
            (g) => {
              'id': g.id,
              'code': g.code,
              'name': g.name,
              'teamSize': g.teamSize,
              'boardSize': g.boardSize,
              'gameMode': g.gameMode,
              'endTime': g.endTime,
              'createdAt': g.createdAt,
            },
          )
          .toList(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch games'},
    );
  }
}

Future<Response> _createGame(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final name = body['name'] as String?;
    final teamSize = body['teamSize'] as int? ?? 5;
    final boardSize = body['boardSize'] as int? ?? 3;
    final gameMode = body['gameMode'] as String? ?? 'blackout';
    final endTimeStr = body['endTime'] as String?;
    final tiles = body['tiles'] as List<dynamic>? ?? [];

    if (name == null || name.trim().isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Game name is required'},
      );
    }

    if (teamSize < 1 || teamSize > 50) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Team size must be between 1 and 50'},
      );
    }

    if (![2, 3, 4, 5].contains(boardSize)) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Board size must be 2, 3, 4, or 5'},
      );
    }

    if (!['blackout', 'points'].contains(gameMode)) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Game mode must be "blackout" or "points"'},
      );
    }

    DateTime? endTime;
    if (endTimeStr != null && endTimeStr.isNotEmpty) {
      endTime = DateTime.tryParse(endTimeStr);
    }

    final requiredTiles = boardSize * boardSize;

    // Allow empty games (tiles can be added later via random board generator)
    if (tiles.isNotEmpty && tiles.length != requiredTiles) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'error':
              'Must have exactly $requiredTiles tiles for ${boardSize}x$boardSize board',
        },
      );
    }

    // Validate points for points mode
    if (gameMode == 'points' && tiles.isNotEmpty) {
      for (var i = 0; i < tiles.length; i++) {
        final t = tiles[i] as Map<String, dynamic>;
        final tilePoints = (t['points'] as num?)?.toInt() ?? 0;
        if (tilePoints <= 0) {
          return Response.json(
            statusCode: HttpStatus.badRequest,
            body: {
              'error': 'Tile ${i + 1} must have points > 0 for points mode',
            },
          );
        }
      }
    }

    final db = context.read<AppDatabase>();
    final id = const Uuid().v4();
    final code = _generateGameCode();
    final now = DateTime.now();

    await db.createGame(
      id: id,
      code: code,
      name: name.trim(),
      teamSize: teamSize,
      boardSize: boardSize,
      gameMode: gameMode,
      endTime: endTime,
      createdAt: now,
    );

    for (var i = 0; i < tiles.length; i++) {
      final t = tiles[i] as Map<String, dynamic>;
      final bossId = t['bossId'] as String?;
      final description = t['description'] as String?;
      final uniqueItems = t['uniqueItems'] as List<dynamic>?;
      final tilePoints = (t['points'] as num?)?.toInt() ?? 0;

      if (bossId == null || bossId.trim().isEmpty) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {'error': 'Boss ID is required for all tiles'},
        );
      }

      // Verify boss exists
      final boss = await db.getBossById(bossId);
      if (boss == null) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {'error': 'Boss not found: $bossId'},
        );
      }

      final isAnyUnique = t['isAnyUnique'] as bool? ?? false;
      final isOrLogic = t['isOrLogic'] as bool? ?? false;
      final anyNCount = (t['anyNCount'] as num?)?.toInt();

      if (!isAnyUnique && (uniqueItems == null || uniqueItems.isEmpty)) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'error':
                'At least one unique item is required for each tile (or use "Any Unique" option)',
          },
        );
      }

      final tileId = const Uuid().v4();
      await db.createBingoTile(
        id: tileId,
        gameId: id,
        bossId: bossId,
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        position: i,
        isAnyUnique: isAnyUnique,
        isOrLogic: isOrLogic,
        anyNCount: anyNCount,
        points: tilePoints,
      );

      // Create unique items for this tile (only if not "any unique")
      if (!isAnyUnique && uniqueItems != null) {
        for (final item in uniqueItems) {
          final itemData = item as Map<String, dynamic>;
          final itemName = itemData['itemName'] as String?;
          final requiredCount =
              (itemData['requiredCount'] as num?)?.toInt() ?? 1;

          if (itemName == null || itemName.trim().isEmpty) {
            continue;
          }

          await db.createTileUniqueItem(
            tileId: tileId,
            itemName: itemName.trim(),
            requiredCount: requiredCount,
          );
        }
      }
    }

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'id': id,
        'code': code,
        'name': name.trim(),
        'teamSize': teamSize,
        'boardSize': boardSize,
        'gameMode': gameMode,
        'endTime': endTime?.toIso8601String(),
        'createdAt': now.toIso8601String(),
      },
    );
  } catch (e, stackTrace) {
    developer.log(
      'Failed to create game',
      name: 'games',
      error: e,
      stackTrace: stackTrace,
    );
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to create game: $e'},
    );
  }
}

String _generateGameCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final random = Random.secure();
  return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
}
