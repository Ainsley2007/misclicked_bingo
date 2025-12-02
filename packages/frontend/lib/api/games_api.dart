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
  Future<Game> updateGame(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/games/{id}')
  Future<void> deleteGame(@Path('id') String id);

  @POST('/games/{code}/join')
  Future<JoinGameResponse> joinGame(@Path('code') String code, @Body() Map<String, dynamic> body);

  @GET('/games/{id}/tiles')
  Future<List<BingoTile>> getTiles(@Path('id') String gameId);

  @GET('/games/{id}/overview')
  Future<GameOverview> getOverview(@Path('id') String gameId);

  @GET('/games/{id}/users')
  Future<List<AppUser>> getGameUsers(@Path('id') String gameId);

  @PUT('/games/{gameId}/tiles/{tileId}')
  Future<void> updateTile(@Path('gameId') String gameId, @Path('tileId') String tileId, @Body() Map<String, dynamic> body);

  @PUT('/games/{gameId}/tiles/{tileId}/complete')
  Future<TileCompletionResponse> toggleTileCompletion(@Path('gameId') String gameId, @Path('tileId') String tileId);

  @POST('/games/{gameId}/tiles/{tileId}/uncomplete-all')
  Future<void> uncompleteTileForAllTeams(@Path('gameId') String gameId, @Path('tileId') String tileId, @Body() Map<String, dynamic> body);

  @GET('/games/{id}/activity')
  Future<List<TileActivity>> getActivity(@Path('id') String gameId, @Query('limit') int? limit);

  @GET('/games/{id}/stats')
  Future<ProofStats> getStats(@Path('id') String gameId);

  @GET('/public/games')
  Future<List<Game>> getPublicGames();

  @GET('/public/games/{id}')
  Future<Game> getPublicGame(@Path('id') String id);

  @GET('/public/games/{id}/overview')
  Future<GameOverview> getPublicOverview(@Path('id') String gameId);

  @GET('/public/games/{id}/activity')
  Future<List<TileActivity>> getPublicActivity(@Path('id') String gameId, @Query('limit') int? limit);

  @GET('/public/games/{id}/stats')
  Future<ProofStats> getPublicStats(@Path('id') String gameId);
}

class JoinGameResponse {
  JoinGameResponse({required this.game, required this.team});

  factory JoinGameResponse.fromJson(Map<String, dynamic> json) {
    return JoinGameResponse(game: Game.fromJson(json['game'] as Map<String, dynamic>), team: Team.fromJson(json['team'] as Map<String, dynamic>));
  }

  final Game game;
  final Team team;

  Map<String, dynamic> toJson() => {'game': game.toJson(), 'team': team.toJson()};
}

class GameOverview {
  GameOverview({required this.game, required this.tiles, required this.teams, required this.leaderboard});

  factory GameOverview.fromJson(Map<String, dynamic> json) {
    return GameOverview(
      game: Game.fromJson(json['game'] as Map<String, dynamic>),
      tiles: (json['tiles'] as List<dynamic>).map((e) => BingoTile.fromJson(e as Map<String, dynamic>)).toList(),
      teams: (json['teams'] as List<dynamic>).map((e) => Team.fromJson(e as Map<String, dynamic>)).toList(),
      leaderboard: (json['leaderboard'] as List<dynamic>).map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final Game game;
  final List<BingoTile> tiles;
  final List<Team> teams;
  final List<LeaderboardEntry> leaderboard;

  Map<String, dynamic> toJson() => {
    'game': game.toJson(),
    'tiles': tiles.map((e) => e.toJson()).toList(),
    'teams': teams.map((e) => e.toJson()).toList(),
    'leaderboard': leaderboard.map((e) => e.toJson()).toList(),
  };
}

class LeaderboardEntry {
  LeaderboardEntry({required this.teamId, required this.teamName, required this.teamColor, required this.points, required this.completedTiles});

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      teamColor: json['teamColor'] as String?,
      points: json['points'] as int,
      completedTiles: json['completedTiles'] as int,
    );
  }

  final String teamId;
  final String teamName;
  final String? teamColor;
  final int points;
  final int completedTiles;

  Map<String, dynamic> toJson() => {'teamId': teamId, 'teamName': teamName, 'teamColor': teamColor, 'points': points, 'completedTiles': completedTiles};
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
