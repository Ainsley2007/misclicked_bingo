import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getChallenges(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getChallenges(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    final challenges = await db.getChallengesByGameId(id);

    return Response.json(
      body: challenges
          .map(
            (c) => {
              'id': c.id,
              'gameId': c.gameId,
              'title': c.title,
              'description': c.description,
              'imageUrl': c.imageUrl,
              'unlockAmount': c.unlockAmount,
            },
          )
          .toList(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch challenges'},
    );
  }
}
