import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/game_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getPublicGames(context),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getPublicGames(RequestContext context) async {
  try {
    final gameService = context.read<GameService>();
    final games = await gameService.getAllGames();

    return ResponseHelper.success(data: games.map((g) => g.toJson()).toList());
  } catch (e) {
    return ResponseHelper.internalError();
  }
}

