import 'dart:convert';

import 'package:backend/database.dart';
import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/game_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(
  RequestContext context,
  String gameId,
  String tileId,
) async {
  return switch (context.request.method) {
    HttpMethod.post => _uncompleteTileForAllTeams(context, gameId, tileId),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _uncompleteTileForAllTeams(
  RequestContext context,
  String gameId,
  String tileId,
) async {
  try {
    final userId = context.read<String>();
    final db = context.read<AppDatabase>();

    final user = await db.getUserById(userId);
    if (user == null || user.role != 'admin') {
      return ResponseHelper.forbidden(message: 'Admin access required');
    }

    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final deleteProofs = data['deleteProofs'] as bool? ?? false;

    final gameService = GameService(db);
    await gameService.uncompleteTileForAllTeams(
      gameId: gameId,
      tileId: tileId,
      deleteProofs: deleteProofs,
    );

    return ResponseHelper.success(data: {'success': true});
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
