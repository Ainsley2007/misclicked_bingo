import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

@immutable
sealed class OverviewState {
  const OverviewState();
}

@immutable
final class OverviewInitial extends OverviewState {
  const OverviewInitial();
}

@immutable
final class OverviewLoading extends OverviewState {
  const OverviewLoading();
}

@immutable
final class OverviewLoaded extends OverviewState {
  const OverviewLoaded({
    required this.game,
    required this.tiles,
    required this.teams,
    this.activities = const [],
    this.stats,
  });

  final Game game;
  final List<BingoTile> tiles;
  final List<TeamOverview> teams;
  final List<TileActivity> activities;
  final ProofStats? stats;

  OverviewLoaded copyWith({
    Game? game,
    List<BingoTile>? tiles,
    List<TeamOverview>? teams,
    List<TileActivity>? activities,
    ProofStats? stats,
  }) {
    return OverviewLoaded(
      game: game ?? this.game,
      tiles: tiles ?? this.tiles,
      teams: teams ?? this.teams,
      activities: activities ?? this.activities,
      stats: stats ?? this.stats,
    );
  }
}

@immutable
final class OverviewError extends OverviewState {
  const OverviewError(this.message);

  final String message;
}

class TeamOverview {
  const TeamOverview({
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
