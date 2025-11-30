// ============================================================
// RANDOM BOARD GENERATOR ENDPOINT - FOR TESTING PURPOSES
// This file can be safely deleted when no longer needed.
// ============================================================

import 'dart:io';

import 'package:backend/database.dart';
import 'package:backend/services/random_board_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.post => _generateRandomBoard(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _generateRandomBoard(
  RequestContext context,
  String id,
) async {
  try {
    final userId = context.read<String>();
    final db = context.read<AppDatabase>();

    final user = await db.getUserById(userId);
    if (user == null || user.role != 'admin') {
      return Response.json(
        statusCode: HttpStatus.forbidden,
        body: {'error': 'Admin access required'},
      );
    }

    final game = await db.getGameById(id);
    if (game == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Game not found'},
      );
    }

    final randomBoardService = RandomBoardService(db);
    await randomBoardService.generateRandomBoard(id);

    return Response.json(body: {'success': true, 'message': '25 random tiles generated'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': e.toString()},
    );
  }
}

