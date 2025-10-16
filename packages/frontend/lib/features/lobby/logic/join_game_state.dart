import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

@immutable
sealed class JoinGameState {
  const JoinGameState();
}

@immutable
final class JoinGameInitial extends JoinGameState {
  const JoinGameInitial();
}

@immutable
final class JoinGameLoading extends JoinGameState {
  const JoinGameLoading();
}

@immutable
final class JoinGameSuccess extends JoinGameState {
  const JoinGameSuccess({required this.game, required this.team});

  final Game game;
  final Team team;
}

@immutable
final class JoinGameError extends JoinGameState {
  const JoinGameError(this.message);

  final String message;
}
