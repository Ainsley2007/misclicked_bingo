import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/activity_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getActivity(context, id),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getActivity(RequestContext context, String gameId) async {
  try {
    final activityService = context.read<ActivityService>();

    final limitParam = context.request.uri.queryParameters['limit'];
    final limit = limitParam != null ? int.tryParse(limitParam) ?? 50 : 50;

    final activities = await activityService.getRecentActivity(
      gameId: gameId,
      limit: limit,
    );

    return ResponseHelper.success(
      data: activities.map((a) => a.toJson()).toList(),
    );
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
