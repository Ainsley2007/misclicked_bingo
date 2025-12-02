import 'dart:convert';

import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/game_service.dart';
import 'package:backend/services/user_service.dart';
import 'package:backend/validators/tile_validator.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(
  RequestContext context,
  String gameId,
  String tileId,
) async {
  return switch (context.request.method) {
    HttpMethod.put => _updateTile(context, gameId, tileId),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _updateTile(
  RequestContext context,
  String gameId,
  String tileId,
) async {
  try {
    final userId = context.read<String>();
    final userService = context.read<UserService>();

    final isAdmin = await userService.isAdmin(userId);
    if (!isAdmin) {
      return ResponseHelper.forbidden(message: 'Admin access required');
    }

    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    final bossId = data['bossId'] as String?;
    final isAnyUnique = data['isAnyUnique'] as bool? ?? false;
    final uniqueItemsData = data['uniqueItems'] as List<dynamic>?;

    final validation = TileValidator.validateTile(
      bossId: bossId,
      isAnyUnique: isAnyUnique,
      uniqueItems: uniqueItemsData,
    );

    if (!validation.isValid) {
      return ResponseHelper.error(
        message: validation.errorMessage!,
        code: validation.errorCode!,
      );
    }

    final uniqueItems = uniqueItemsData?.map((item) {
      final itemMap = item as Map<String, dynamic>;
      return TileUniqueItemData(
        itemName: itemMap['itemName'] as String,
        requiredCount: itemMap['requiredCount'] as int? ?? 1,
      );
    }).toList();

    final gameService = context.read<GameService>();
    await gameService.updateTile(
      tileId: tileId,
      bossId: bossId!,
      description: data['description'] as String?,
      isAnyUnique: isAnyUnique,
      isOrLogic: data['isOrLogic'] as bool? ?? false,
      anyNCount: data['anyNCount'] as int?,
      uniqueItems: uniqueItems,
    );

    return ResponseHelper.success(data: {'success': true});
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
