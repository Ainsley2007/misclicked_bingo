import 'dart:io';

import 'package:backend/database.dart';
import 'package:backend/services/proofs_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
  String tileId,
) async {
  return switch (context.request.method) {
    HttpMethod.get => _getPublicProofs(context, id, tileId),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getPublicProofs(
  RequestContext context,
  String gameId,
  String tileId,
) async {
  try {
    final db = context.read<AppDatabase>();

    final teamIdParam = context.request.uri.queryParameters['teamId'];
    if (teamIdParam == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'teamId query parameter is required'},
      );
    }

    final proofsService = ProofsService(db, null);
    final proofs = await proofsService.getProofsForTile(
      tileId: tileId,
      teamId: teamIdParam,
    );

    return Response.json(body: proofs.map((p) => p.toJson()).toList());
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch proofs: $e'},
    );
  }
}

