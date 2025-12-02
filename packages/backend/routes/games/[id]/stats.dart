import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/activity_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getStats(context, id),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getStats(RequestContext context, String gameId) async {
  try {
    final activityService = context.read<ActivityService>();
    final stats = await activityService.getStats(gameId: gameId);
    return ResponseHelper.success(data: stats.toJson());
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
