import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  // Check if user is admin
  final payload = context.read<Map<String, dynamic>?>();
  if (payload == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': 'Unauthorized'},
    );
  }

  final userId = payload['sub'] as String?;
  if (userId == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: {'error': 'Unauthorized'},
    );
  }

  final db = context.read<AppDatabase>();
  final user = await db.getUserById(userId);
  if (user == null || user.role != 'admin') {
    return Response.json(
      statusCode: HttpStatus.forbidden,
      body: {'error': 'Forbidden - Admin access required'},
    );
  }

  return switch (context.request.method) {
    HttpMethod.post => _createBoss(context),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _createBoss(RequestContext context) async {
  try {
    final db = context.read<AppDatabase>();
    final body = await context.request.json() as Map<String, dynamic>;
    final name = body['name'] as String?;
    final type = body['type'] as String?;
    final iconUrl = body['iconUrl'] as String?;
    final uniqueItems = body['uniqueItems'] as List<dynamic>?;

    if (name == null || name.trim().isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Boss name is required'},
      );
    }

    if (type == null || type.trim().isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Boss type is required'},
      );
    }

    if (iconUrl == null || iconUrl.trim().isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Boss icon URL is required'},
      );
    }

    if (uniqueItems == null || uniqueItems.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'At least one unique item is required'},
      );
    }

    const uuid = Uuid();
    final bossId = uuid.v4();
    final now = DateTime.now();

    await db.createBoss(
      id: bossId,
      name: name.trim(),
      type: type.trim(),
      iconUrl: iconUrl.trim(),
      createdAt: now,
    );

    // Create unique items
    for (final item in uniqueItems) {
      final itemName = item as String;
      if (itemName.trim().isNotEmpty) {
        await db.createBossUniqueItem(
          bossId: bossId,
          itemName: itemName.trim(),
        );
      }
    }

    // Return the created boss with its unique items
    final boss = await db.getBossById(bossId);
    if (boss == null) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': 'Failed to create boss'},
      );
    }

    final uniqueItemsList = await db.getUniqueItemsByBossId(bossId);

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'id': boss.id,
        'name': boss.name,
        'type': boss.type,
        'iconUrl': boss.iconUrl,
        'uniqueItems': uniqueItemsList.map((item) => item.itemName).toList(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to create boss: $e'},
    );
  }
}
