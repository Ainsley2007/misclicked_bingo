import 'package:equatable/equatable.dart';

sealed class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

final class GameLoadRequested extends GameEvent {
  const GameLoadRequested(this.gameId);

  final String gameId;

  @override
  List<Object?> get props => [gameId];
}
