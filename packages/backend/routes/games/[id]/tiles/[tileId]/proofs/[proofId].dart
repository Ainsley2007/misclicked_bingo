import 'dart:io';

import 'package:backend/database.dart';
import 'package:backend/services/proofs_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
  String tileId,
  String proofId,
) async {
  return switch (context.request.method) {
    HttpMethod.delete => _deleteProof(context, id, tileId, proofId),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _deleteProof(
  RequestContext context,
  String gameId,
  String tileId,
  String proofId,
) async {
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

    final tileStatus = await db.getTeamBoardState(
      teamId: user.teamId!,
      tileId: tileId,
    );
    if (tileStatus == 'completed') {
      return Response.json(
        statusCode: HttpStatus.forbidden,
        body: {'error': 'Cannot delete proof from completed tile'},
      );
    }

    await proofsService.deleteProof(proofId);

    return Response.json(body: {'success': true});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to delete proof: $e'},
    );
  }
}

