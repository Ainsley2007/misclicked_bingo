import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/activity_service.dart';
import 'package:backend/services/game_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getPublicActivity(context, id),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getPublicActivity(RequestContext context, String id) async {
  try {
    final gameService = context.read<GameService>();
    
    final game = await gameService.getGameById(id);
    if (game == null) {
      return ResponseHelper.notFound(message: 'Game not found');
    }

    final limitParam = context.request.uri.queryParameters['limit'];
    final limit = limitParam != null ? int.tryParse(limitParam) ?? 50 : 50;

    final activityService = context.read<ActivityService>();
    final activities = await activityService.getRecentActivity(
      gameId: id,
      limit: limit,
    );

    return ResponseHelper.success(
      data: activities.map((a) => a.toJson()).toList(),
    );
  } catch (e) {
    return ResponseHelper.internalError();
  }
}

