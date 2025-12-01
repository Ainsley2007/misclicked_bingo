import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getPublicGameOverview(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _getPublicGameOverview(
  RequestContext context,
  String id,
) async {
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
          'game': {
            ...game.toJson(),
            'gameMode': game.gameMode,
            'endTime': game.endTime,
          },
          'tiles': <Map<String, dynamic>>[],
          'teams': <Map<String, dynamic>>[],
          'totalPoints': 0,
        },
      );
    }

    final tileIds = tiles.map((t) => t.id).toList();

    final allTeamBoardStatesFutures = <Future<Map<String, String>>>[
      for (final team in teams) db.getTeamBoardStates(team.id),
    ];
    final allTeamProofsFutures = <Future<List<TileProof>>>[
      for (final team in teams) db.getProofsByTeam(team.id),
    ];
    final futures = await Future.wait([
      db.getAllBosses(),
      db.getUniqueItemsByTileIds(tileIds),
      Future.wait<Map<String, String>>(allTeamBoardStatesFutures),
      Future.wait<List<TileProof>>(allTeamProofsFutures),
    ]);

    final allBosses = futures[0] as List<BossesData>;
    final allUniqueItems = futures[1] as List<TileUniqueItem>;
    final allTeamBoardStates = futures[2] as List<Map<String, String>>;
    final allTeamProofs = futures[3] as List<List<TileProof>>;

    final bossMap = {
      for (final boss in allBosses) boss.id: boss,
    };
    final uniqueItemsMap = <String, List<TileUniqueItem>>{};
    for (final item in allUniqueItems) {
      uniqueItemsMap.putIfAbsent(item.tileId, () => []).add(item);
    }

    // Create tile points map for calculating team points
    final tilePointsMap = {for (final t in tiles) t.id: t.points};
    final totalPoints = tiles.fold<int>(0, (sum, t) => sum + t.points);

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
        'points': t.points,
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

    final teamsData = teams.asMap().entries.map((entry) {
      final team = entry.value;
      final teamBoardStates = allTeamBoardStates[entry.key];
      final teamProofs = allTeamProofs[entry.key];

      // Build set of tiles with proofs for this team
      final tilesWithProofs = <String>{};
      for (final proof in teamProofs) {
        tilesWithProofs.add(proof.tileId);
      }

      // Calculate team points (sum of completed tile points)
      var teamPoints = 0;
      for (final entry in teamBoardStates.entries) {
        if (entry.value == 'completed') {
          teamPoints += tilePointsMap[entry.key] ?? 0;
        }
      }

      return {
        'id': team.id,
        'name': team.name,
        'color': team.color,
        'gameId': team.gameId,
        'captainUserId': team.captainUserId,
        'boardStates': teamBoardStates,
        'tilesWithProofs': tilesWithProofs.toList(),
        'teamPoints': teamPoints,
      };
    }).toList();

    return Response.json(
      body: {
        'game': {
          ...game.toJson(),
          'gameMode': game.gameMode,
          'endTime': game.endTime,
        },
        'tiles': tilesData,
        'teams': teamsData,
        'totalPoints': totalPoints,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to fetch game overview: $e'},
    );
  }
}

