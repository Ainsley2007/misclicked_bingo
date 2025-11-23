import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getBosses(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getBosses(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final bosses = await db.getAllBosses();

    // Get unique items for each boss
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

    return Response.json(body: bossesWithItems);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch bosses: $e'},
    );
  }
}
