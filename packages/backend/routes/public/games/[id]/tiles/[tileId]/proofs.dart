import 'dart:io';

import 'package:backend/database.dart' hide TileProof;
import 'package:dart_frog/dart_frog.dart';
import 'package:shared_models/shared_models.dart';

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

    final proofs = await db.getProofsByTileAndTeam(
      tileId: tileId,
      teamId: teamIdParam,
    );

    final userIds = proofs.map((p) => p.uploadedByUserId).toSet();
    final users = <String, User>{};
    for (final userId in userIds) {
      final user = await db.getUserById(userId);
      if (user != null) users[userId] = user;
    }

    final result = proofs.map((p) {
      final user = users[p.uploadedByUserId];
      return TileProof(
        id: p.id,
        teamId: p.teamId,
        tileId: p.tileId,
        imageUrl: p.imageUrl,
        uploadedByUserId: p.uploadedByUserId,
        uploadedByUsername: user?.globalName ?? user?.username,
        uploadedAt: DateTime.parse(p.uploadedAt),
      ).toJson();
    }).toList();

    return Response.json(body: result);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch proofs: $e'},
    );
  }
}
