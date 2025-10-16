import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getTiles(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getTiles(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    final tiles = await db.getTilesByGameId(id);

    return Response.json(
      body: tiles
          .map(
            (t) => {
              'id': t.id,
              'gameId': t.gameId,
              'title': t.title,
              'description': t.description,
              'imageUrl': t.imageUrl,
              'position': t.position,
            },
          )
          .toList(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch tiles'},
    );
  }
}
