import 'package:backend/database.dart';
import 'package:backend/helpers/response_helper.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getBosses(context),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getBosses(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final bosses = await db.getAllBosses();

    final bossesWithItems = await Future.wait(
      bosses.map((boss) async {
        final uniqueItems = await db.getUniqueItemsByBossId(boss.id);
        return {
          'id': boss.id,
          'name': boss.name,
          'type': boss.type,
          'iconUrl': boss.iconUrl,
          'uniqueItems': uniqueItems.map((item) => item.itemName).toList(),
        };
      }),
    );

    return ResponseHelper.success(data: bossesWithItems);
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
