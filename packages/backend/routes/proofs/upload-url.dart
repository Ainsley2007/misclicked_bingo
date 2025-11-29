import 'dart:io';

import 'package:backend/database.dart';
import 'package:backend/services/proofs_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _getUploadUrl(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getUploadUrl(RequestContext context) async {
  try {
    final userId = context.read<String>();
    final db = context.read<AppDatabase>();
    final proofsService = context.read<ProofsService>();

    final user = await db.getUserById(userId);
    if (user == null || user.teamId == null) {
      return Response.json(
        statusCode: HttpStatus.forbidden,
        body: {'error': 'User must be part of a team'},
      );
    }

    final body = await context.request.json() as Map<String, dynamic>;
    final gameId = body['gameId'] as String?;
    final fileName = body['fileName'] as String?;

    if (gameId == null || fileName == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Missing required fields: gameId, fileName'},
      );
    }

    final result = await proofsService.getPresignedUploadUrl(
      gameId: gameId,
      teamId: user.teamId!,
      fileName: fileName,
    );

    return Response.json(body: result);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to generate upload URL: $e'},
    );
  }
}

