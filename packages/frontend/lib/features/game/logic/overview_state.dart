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
  });

  final Game game;
  final List<BingoTile> tiles;
  final List<TeamOverview> teams;
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
    required this.boardStates,
  });

  final String id;
  final String name;
  final Map<String, String> boardStates;
}
