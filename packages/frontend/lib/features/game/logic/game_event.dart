sealed class GameEvent {
  const GameEvent();
}

final class GameLoadRequested extends GameEvent {
  const GameLoadRequested(this.gameId);

  final String gameId;
}
