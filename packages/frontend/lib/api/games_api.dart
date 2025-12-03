import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shared_models/shared_models.dart';

part 'games_api.g.dart';

@RestApi()
abstract class GamesApi {
  factory GamesApi(Dio dio, {String? baseUrl}) = _GamesApi;

  @GET('/games')
  Future<List<Game>> getGames();

  @POST('/games')
  Future<Game> createGame(@Body() Map<String, dynamic> body);

  @GET('/games/{id}')
  Future<Game> getGame(@Path('id') String id);

  @PUT('/games/{id}')
  Future<Game> updateGame(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/games/{id}')
  Future<void> deleteGame(@Path('id') String id);

  @POST('/games/{code}/join')
  Future<JoinGameResponse> joinGame(
    @Path('code') String code,
    @Body() Map<String, dynamic> body,
  );

  @GET('/games/{id}/tiles')
  Future<List<BingoTile>> getTiles(@Path('id') String gameId);

  @GET('/games/{id}/overview')
  Future<GameOverview> getOverview(@Path('id') String gameId);

  @GET('/games/{id}/users')
  Future<List<AppUser>> getGameUsers(@Path('id') String gameId);

  @PUT('/games/{gameId}/tiles/{tileId}')
  Future<void> updateTile(
    @Path('gameId') String gameId,
    @Path('tileId') String tileId,
    @Body() Map<String, dynamic> body,
  );

  @PUT('/games/{gameId}/tiles/{tileId}/complete')
  Future<TileCompletionResponse> toggleTileCompletion(
    @Path('gameId') String gameId,
    @Path('tileId') String tileId,
  );

  @POST('/games/{gameId}/tiles/{tileId}/uncomplete-all')
  Future<void> uncompleteTileForAllTeams(
    @Path('gameId') String gameId,
    @Path('tileId') String tileId,
    @Body() Map<String, dynamic> body,
  );

  @GET('/games/{id}/activity')
  Future<List<TileActivity>> getActivity(
    @Path('id') String gameId,
    @Query('limit') int? limit,
  );

  @GET('/games/{id}/stats')
  Future<ProofStats> getStats(@Path('id') String gameId);

  @GET('/public/games')
  Future<List<Game>> getPublicGames();

  @GET('/public/games/{id}')
  Future<Game> getPublicGame(@Path('id') String id);

  @GET('/public/games/{id}/overview')
  Future<GameOverview> getPublicOverview(@Path('id') String gameId);

  @GET('/public/games/{id}/activity')
  Future<List<TileActivity>> getPublicActivity(
    @Path('id') String gameId,
    @Query('limit') int? limit,
  );

  @GET('/public/games/{id}/stats')
  Future<ProofStats> getPublicStats(@Path('id') String gameId);
}

class JoinGameResponse {
  JoinGameResponse({required this.game, required this.team});

  factory JoinGameResponse.fromJson(Map<String, dynamic> json) {
    return JoinGameResponse(
      game: Game.fromJson(json['game'] as Map<String, dynamic>),
      team: Team.fromJson(json['team'] as Map<String, dynamic>),
    );
  }

  final Game game;
  final Team team;

  Map<String, dynamic> toJson() => {
    'game': game.toJson(),
    'team': team.toJson(),
  };
}

class GameOverview {
  GameOverview({
    required this.game,
    required this.tiles,
    required this.teams,
    this.totalPoints = 0,
  });

  factory GameOverview.fromJson(Map<String, dynamic> json) {
    return GameOverview(
      game: Game.fromJson(json['game'] as Map<String, dynamic>),
      tiles: (json['tiles'] as List<dynamic>)
          .map((e) => BingoTile.fromJson(e as Map<String, dynamic>))
          .toList(),
      teams: (json['teams'] as List<dynamic>)
          .map((e) => OverviewTeam.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPoints: json['totalPoints'] as int? ?? 0,
    );
  }

  final Game game;
  final List<BingoTile> tiles;
  final List<OverviewTeam> teams;
  final int totalPoints;

  Map<String, dynamic> toJson() => {
    'game': game.toJson(),
    'tiles': tiles.map((e) => e.toJson()).toList(),
    'teams': teams.map((e) => e.toJson()).toList(),
    'totalPoints': totalPoints,
  };
}

class OverviewTeam {
  OverviewTeam({
    required this.id,
    required this.name,
    required this.color,
    required this.gameId,
    this.captainUserId,
    required this.boardStates,
    required this.tilesWithProofs,
    this.teamPoints = 0,
  });

  factory OverviewTeam.fromJson(Map<String, dynamic> json) {
    return OverviewTeam(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String? ?? '#4CAF50',
      gameId: json['gameId'] as String,
      captainUserId: json['captainUserId'] as String?,
      boardStates:
          (json['boardStates'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as String),
          ) ??
          {},
      tilesWithProofs:
          (json['tilesWithProofs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      teamPoints: json['teamPoints'] as int? ?? 0,
    );
  }

  final String id;
  final String name;
  final String color;
  final String gameId;
  final String? captainUserId;
  final Map<String, String> boardStates;
  final List<String> tilesWithProofs;
  final int teamPoints;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'gameId': gameId,
    'captainUserId': captainUserId,
    'boardStates': boardStates,
    'tilesWithProofs': tilesWithProofs,
    'teamPoints': teamPoints,
  };
}

class TileCompletionResponse {
  TileCompletionResponse({required this.status});

  factory TileCompletionResponse.fromJson(Map<String, dynamic> json) {
    return TileCompletionResponse(status: json['status'] as String);
  }

  final String status;

  bool get isCompleted => status == 'completed';

  Map<String, dynamic> toJson() => {'status': status};
}
