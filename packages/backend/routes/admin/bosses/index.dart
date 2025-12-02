import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/boss_service.dart';
import 'package:backend/services/user_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final payload = context.read<Map<String, dynamic>?>();
  if (payload == null) {
    return ResponseHelper.unauthorized();
  }

  final userId = payload['sub'] as String?;
  if (userId == null) {
    return ResponseHelper.unauthorized();
  }

  final userService = context.read<UserService>();
  
  final isAdmin = await userService.isAdmin(userId);
  if (!isAdmin) {
    return ResponseHelper.forbidden(message: 'Admin access required');
  }

  return switch (context.request.method) {
    HttpMethod.post => _createBoss(context),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _createBoss(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final name = body['name'] as String?;
    final type = body['type'] as String?;
    final iconUrl = body['iconUrl'] as String?;
    final uniqueItems = body['uniqueItems'] as List<dynamic>?;

    if (name == null || name.trim().isEmpty) {
      return ResponseHelper.validationError(message: 'Boss name is required');
    }

    if (type == null || type.trim().isEmpty) {
      return ResponseHelper.validationError(message: 'Boss type is required');
    }

    if (iconUrl == null || iconUrl.trim().isEmpty) {
      return ResponseHelper.validationError(
        message: 'Boss icon URL is required',
      );
    }

    if (uniqueItems == null || uniqueItems.isEmpty) {
      return ResponseHelper.validationError(
        message: 'At least one unique item is required',
      );
    }

    final bossService = context.read<BossService>();
    final boss = await bossService.createBoss(
      name: name,
      type: type,
      iconUrl: iconUrl,
      uniqueItems: uniqueItems.map((item) => item as String).toList(),
    );

    return ResponseHelper.created(data: boss);
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
