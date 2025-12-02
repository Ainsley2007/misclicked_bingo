import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/tiles_service.dart';
import 'package:backend/services/user_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getTiles(context, id),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getTiles(RequestContext context, String id) async {
  try {
    final tilesService = context.read<TilesService>();
    final userService = context.read<UserService>();

    final userId = context.read<String>();
    final teamId = await userService.getUserTeamId(userId);

    final tiles = await tilesService.getEnrichedTilesForGame(
      gameId: id,
      teamId: teamId,
    );

    return ResponseHelper.success(
      data: tiles.map((tile) => tile.toJson()).toList(),
    );
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
