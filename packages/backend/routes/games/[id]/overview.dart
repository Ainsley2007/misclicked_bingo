import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getOverview(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getOverview(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    final game = await db.getGameById(id);
    if (game == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'Game not found'},
      );
    }

    final teams = await db.getTeamsByGameId(id);
    final tiles = await db.getTilesByGameId(id);

    if (tiles.isEmpty) {
      return Response.json(
        body: {
          'game': game.toJson(),
          'teams': <Map<String, dynamic>>[],
        },
      );
    }

    final tileIds = tiles.map((t) => t.id).toList();

    // Fetch all bosses, unique items, and all teams' board states in parallel
    final allTeamBoardStatesFutures = <Future<Map<String, String>>>[
      for (final team in teams) db.getTeamBoardStates(team.id),
    ];
    final futures = await Future.wait([
      db.getAllBosses(),
      db.getUniqueItemsByTileIds(tileIds),
      Future.wait<Map<String, String>>(allTeamBoardStatesFutures),
    ]);

    final allBosses = futures[0] as List<BossesData>;
    final allUniqueItems = futures[1] as List<TileUniqueItem>;
    final allTeamBoardStates = futures[2] as List<Map<String, String>>;

    // Create lookup maps
    final bossMap = {
      for (final boss in allBosses) boss.id: boss,
    };
    final uniqueItemsMap = <String, List<TileUniqueItem>>{};
    for (final item in allUniqueItems) {
      uniqueItemsMap.putIfAbsent(item.tileId, () => []).add(item);
    }

    // Build tiles data
    final tilesData = tiles.map((t) {
      final boss = bossMap[t.bossId];
      final uniqueItems = uniqueItemsMap[t.id] ?? [];

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

    // Build teams data with their completion states
    final teamsData = teams.asMap().entries.map((entry) {
      final team = entry.value;
      final teamBoardStates = allTeamBoardStates[entry.key];

      return {
        'id': team.id,
        'name': team.name,
        'color': team.color,
        'gameId': team.gameId,
        'captainUserId': team.captainUserId,
        'boardStates': teamBoardStates,
      };
    }).toList();

    return Response.json(
      body: {
        'game': game.toJson(),
        'tiles': tilesData,
        'teams': teamsData,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch overview: $e'},
    );
  }
}
