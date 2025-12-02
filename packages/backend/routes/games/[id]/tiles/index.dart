import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/tiles_service.dart';
import 'package:backend/services/user_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getTiles(context, id),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getTiles(RequestContext context, String id) async {
  try {
    final tilesService = context.read<TilesService>();
    final userService = context.read<UserService>();
    
    final tiles = await tilesService.getTilesByGameId(id);

    if (tiles.isEmpty) {
      return ResponseHelper.success(data: <Map<String, dynamic>>[]);
    }

    final tileIds = tiles.map((t) => t.id).toList();

    final userId = context.read<String>();
    final teamId = await userService.getUserTeamId(userId);

    final futures = await Future.wait([
      tilesService.getAllBosses(),
      tilesService.getUniqueItemsByTileIds(tileIds),
      if (teamId != null)
        tilesService.getTeamBoardStates(teamId)
      else
        Future.value(<String, String>{}),
      if (teamId != null)
        tilesService.getProofsByTeam(teamId)
      else
        Future.value(<TileProof>[]),
    ]);

    final allBosses = futures[0] as List<BossesData>;
    final allUniqueItems = futures[1] as List<TileUniqueItem>;
    final completionStates = futures[2] as Map<String, String>;
    final allProofs = futures[3] as List<TileProof>;

    final bossMap = {
      for (final boss in allBosses) boss.id: boss,
    };
    final uniqueItemsMap = <String, List<TileUniqueItem>>{};
    for (final item in allUniqueItems) {
      uniqueItemsMap.putIfAbsent(item.tileId, () => []).add(item);
    }
    final tilesWithProofs = <String>{};
    for (final proof in allProofs) {
      tilesWithProofs.add(proof.tileId);
    }

    final tilesWithData = tiles.map((t) {
      final boss = bossMap[t.bossId];
      final uniqueItems = uniqueItemsMap[t.id] ?? [];
      final isCompleted = completionStates[t.id] == 'completed';
      final hasProofs = tilesWithProofs.contains(t.id);

      return {
        'id': t.id,
        'gameId': t.gameId,
        'bossId': t.bossId,
        'bossName': boss?.name,
        'bossType': boss?.type,
        'bossIconUrl': boss?.iconUrl,
        'description': t.description,
        'position': t.position,
        'isAnyUnique': t.isAnyUnique,
        'isOrLogic': t.isOrLogic,
        'anyNCount': t.anyNCount,
        'points': t.points,
        'isCompleted': isCompleted,
        'hasProofs': hasProofs,
        'uniqueItems': uniqueItems
            .map(
              (item) => {
                'itemName': item.itemName,
                'requiredCount': item.requiredCount,
              },
            )
            .toList(),
      };
    }).toList();

    return ResponseHelper.success(data: tilesWithData);
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
