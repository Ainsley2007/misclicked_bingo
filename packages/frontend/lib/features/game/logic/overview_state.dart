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
    this.totalPoints = 0,
    this.activities = const [],
    this.stats,
    this.isSidebarLoading = true,
  });

  final Game game;
  final List<BingoTile> tiles;
  final List<TeamOverview> teams;
  final int totalPoints;
  final List<TileActivity> activities;
  final ProofStats? stats;
  final bool isSidebarLoading;

  OverviewLoaded copyWith({
    Game? game,
    List<BingoTile>? tiles,
    List<TeamOverview>? teams,
    int? totalPoints,
    List<TileActivity>? activities,
    ProofStats? stats,
    bool? isSidebarLoading,
  }) {
    return OverviewLoaded(
      game: game ?? this.game,
      tiles: tiles ?? this.tiles,
      teams: teams ?? this.teams,
      totalPoints: totalPoints ?? this.totalPoints,
      activities: activities ?? this.activities,
      stats: stats ?? this.stats,
      isSidebarLoading: isSidebarLoading ?? this.isSidebarLoading,
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
    this.tilesWithProofs = const [],
    this.teamPoints = 0,
  });

  final String id;
  final String name;
  final String color;
  final Map<String, String> boardStates;
  final List<String> tilesWithProofs;
  final int teamPoints;
}
