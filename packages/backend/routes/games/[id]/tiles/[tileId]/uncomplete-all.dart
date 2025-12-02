import 'dart:convert';

import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/game_service.dart';
import 'package:backend/services/user_service.dart';
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
    final userService = context.read<UserService>();

    final isAdmin = await userService.isAdmin(userId);
    if (!isAdmin) {
      return ResponseHelper.forbidden(message: 'Admin access required');
    }

    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final deleteProofs = data['deleteProofs'] as bool? ?? false;

    final gameService = context.read<GameService>();
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
