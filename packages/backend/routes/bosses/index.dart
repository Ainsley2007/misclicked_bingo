import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/boss_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getBosses(context),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getBosses(RequestContext context) async {
  try {
    final bossService = context.read<BossService>();
    final bossesWithItems = await bossService.getAllBossesWithItems();

    return ResponseHelper.success(data: bossesWithItems);
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
