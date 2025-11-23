import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

@immutable
sealed class GameState {
  const GameState();
}

@immutable
final class GameInitial extends GameState {
  const GameInitial();
}

@immutable
final class GameLoading extends GameState {
  const GameLoading();
}

@immutable
final class GameLoaded extends GameState {
  const GameLoaded({
    required this.game,
    required this.tiles,
    this.users = const [],
  });

  final Game game;
  final List<BingoTile> tiles;
  final List<AppUser> users;
}

@immutable
final class GameError extends GameState {
  const GameError(this.message);

  final String message;
}
