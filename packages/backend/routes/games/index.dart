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
              'hasChallenges': g.hasChallenges,
              'boardSize': g.boardSize,
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
    final hasChallenges = body['hasChallenges'] as bool? ?? false;
    final boardSize = body['boardSize'] as int? ?? 3;
    final challenges = body['challenges'] as List<dynamic>? ?? [];
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

    final requiredTiles = boardSize * boardSize;

    if (tiles.length != requiredTiles) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'error':
              'Must have exactly $requiredTiles tiles for ${boardSize}x$boardSize board',
        },
      );
    }

    if (hasChallenges) {
      if (challenges.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'error':
                'At least one challenge required when challenges are enabled',
          },
        );
      }

      final totalUnlockAmount = challenges.fold<int>(
        0,
        (sum, c) =>
            sum + ((c as Map<String, dynamic>)['unlockAmount'] as int? ?? 0),
      );

      if (totalUnlockAmount < requiredTiles) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'error':
                'Total unlock amount ($totalUnlockAmount) must be at least $requiredTiles',
          },
        );
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
      hasChallenges: hasChallenges,
      boardSize: boardSize,
      createdAt: now,
    );

    for (final challengeData in challenges) {
      final c = challengeData as Map<String, dynamic>;
      await db.createChallenge(
        id: const Uuid().v4(),
        gameId: id,
        title: c['title'] as String,
        description: c['description'] as String,
        imageUrl: c['imageUrl'] as String,
        unlockAmount: c['unlockAmount'] as int,
      );
    }

    for (var i = 0; i < tiles.length; i++) {
      final t = tiles[i] as Map<String, dynamic>;
      await db.createBingoTile(
        id: const Uuid().v4(),
        gameId: id,
        title: t['title'] as String,
        description: t['description'] as String,
        imageUrl: t['imageUrl'] as String,
        position: i,
      );
    }

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'id': id,
        'code': code,
        'name': name.trim(),
        'teamSize': teamSize,
        'hasChallenges': hasChallenges,
        'boardSize': boardSize,
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
