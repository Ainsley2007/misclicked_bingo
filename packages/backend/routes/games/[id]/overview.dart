import 'package:backend/database.dart';
import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/game_service.dart';
import 'package:backend/services/teams_service.dart';
import 'package:backend/services/tiles_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getOverview(context, id),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getOverview(RequestContext context, String id) async {
  try {
    final gameService = context.read<GameService>();
    final tilesService = context.read<TilesService>();
    final teamsService = context.read<TeamsService>();
    
    final game = await gameService.getGameById(id);
    if (game == null) {
      return ResponseHelper.notFound(message: 'Game not found');
    }

    final teams = await teamsService.getTeamsByGameId(id);
    final tiles = await tilesService.getTilesByGameId(id);

    if (tiles.isEmpty) {
      return ResponseHelper.success(
        data: {
          'game': game.toJson(),
          'tiles': <Map<String, dynamic>>[],
          'teams': <Map<String, dynamic>>[],
        },
      );
    }

    final tileIds = tiles.map((t) => t.id).toList();

    final allTeamBoardStatesFutures = <Future<Map<String, String>>>[
      for (final team in teams) tilesService.getTeamBoardStates(team.id),
    ];
    final allTeamProofsFutures = <Future<List<TileProof>>>[
      for (final team in teams) tilesService.getProofsByTeam(team.id),
    ];
    final futures = await Future.wait([
      tilesService.getAllBosses(),
      tilesService.getUniqueItemsByTileIds(tileIds),
      Future.wait<Map<String, String>>(allTeamBoardStatesFutures),
      Future.wait<List<TileProof>>(allTeamProofsFutures),
    ]);

    final allBosses = futures[0] as List<BossesData>;
    final allUniqueItems = futures[1] as List<TileUniqueItem>;
    final allTeamBoardStates = futures[2] as List<Map<String, String>>;
    final allTeamProofs = futures[3] as List<List<TileProof>>;

    // Create lookup maps
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

    final teamsResult = teams.asMap().entries.map((entry) {
      final team = entry.value;
      final teamBoardStates = allTeamBoardStates[entry.key];
      final teamProofs = allTeamProofs[entry.key];

      final tilesWithProofs = <String>{};
      for (final proof in teamProofs) {
        tilesWithProofs.add(proof.tileId);
      }

      var teamPoints = 0;
      for (final stateEntry in teamBoardStates.entries) {
        if (stateEntry.value == 'completed') {
          teamPoints += tilePointsMap[stateEntry.key] ?? 0;
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

    return ResponseHelper.success(
      data: {
        'game': game.toJson(),
        'tiles': tilesData,
        'teams': teamsResult,
        'totalPoints': totalPoints,
      },
    );
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
