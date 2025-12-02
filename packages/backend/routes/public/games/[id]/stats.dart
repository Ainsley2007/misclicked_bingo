import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/activity_service.dart';
import 'package:backend/services/game_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getPublicStats(context, id),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getPublicStats(RequestContext context, String id) async {
  try {
    final gameService = context.read<GameService>();
    
    final game = await gameService.getGameById(id);
    if (game == null) {
      return ResponseHelper.notFound(message: 'Game not found');
    }

    final activityService = context.read<ActivityService>();
    final stats = await activityService.getStats(gameId: id);

    return ResponseHelper.success(data: stats.toJson());
  } catch (e) {
    return ResponseHelper.internalError();
  }
}

