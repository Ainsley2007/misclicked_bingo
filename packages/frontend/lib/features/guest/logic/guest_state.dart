import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

@immutable
sealed class GuestState {
  const GuestState();
}

@immutable
final class GuestInitial extends GuestState {
  const GuestInitial();
}

@immutable
final class GuestLoading extends GuestState {
  const GuestLoading();
}

@immutable
final class GuestGamesLoaded extends GuestState {
  const GuestGamesLoaded(this.games);

  final List<Game> games;
}

@immutable
final class GuestGameOverviewLoaded extends GuestState {
  const GuestGameOverviewLoaded({
    required this.game,
    required this.tiles,
    required this.teams,
    this.activities = const [],
    this.stats,
  });

  final Game game;
  final List<BingoTile> tiles;
  final List<GuestTeamOverview> teams;
  final List<TileActivity> activities;
  final ProofStats? stats;
}

@immutable
final class GuestError extends GuestState {
  const GuestError(this.message);

  final String message;
}

class GuestTeamOverview {
  const GuestTeamOverview({
    required this.id,
    required this.name,
    required this.color,
    required this.boardStates,
  });

  final String id;
  final String name;
  final String color;
  final Map<String, String> boardStates;
}

