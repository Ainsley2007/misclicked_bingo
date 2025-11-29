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
    HttpMethod.get => _getProofs(context, tileId),
    HttpMethod.post => _createProof(context, tileId),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getProofs(RequestContext context, String tileId) async {
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

    final proofs = await proofsService.getProofsForTile(
      tileId: tileId,
      teamId: user.teamId!,
    );

    return Response.json(body: proofs.map((p) => p.toJson()).toList());
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch proofs: $e'},
    );
  }
}

Future<Response> _createProof(RequestContext context, String tileId) async {
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
        body: {'error': 'Cannot add proof to completed tile'},
      );
    }

    final body = await context.request.json() as Map<String, dynamic>;
    final imageUrl = body['imageUrl'] as String?;

    if (imageUrl == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Missing required field: imageUrl'},
      );
    }

    final existingProofs = await proofsService.getProofsForTile(
      tileId: tileId,
      teamId: user.teamId!,
    );

    if (existingProofs.length >= 10) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Maximum of 10 proofs per tile'},
      );
    }

    final proof = await proofsService.createProof(
      teamId: user.teamId!,
      tileId: tileId,
      imageUrl: imageUrl,
      uploadedByUserId: userId,
    );

    return Response.json(statusCode: HttpStatus.created, body: proof.toJson());
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to create proof: $e'},
    );
  }
}

