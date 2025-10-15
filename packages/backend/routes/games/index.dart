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

    final db = context.read<AppDatabase>();
    final id = const Uuid().v4();
    final code = _generateGameCode();
    final now = DateTime.now();

    await db.createGame(
      id: id,
      code: code,
      name: name.trim(),
      teamSize: teamSize,
      createdAt: now,
    );

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'id': id,
        'code': code,
        'name': name.trim(),
        'teamSize': teamSize,
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
      body: {'error': 'Failed to create game'},
    );
  }
}

String _generateGameCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final random = Random.secure();
  return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
}
