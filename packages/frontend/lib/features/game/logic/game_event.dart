sealed class GameEvent {
  const GameEvent();
}

final class GameLoadRequested extends GameEvent {
  const GameLoadRequested(this.gameId);

  final String gameId;
}

final class TileCompletionToggled extends GameEvent {
  const TileCompletionToggled({required this.gameId, required this.tileId});

  final String gameId;
  final String tileId;
}

final class TileProofsUpdated extends GameEvent {
  const TileProofsUpdated({required this.tileId, required this.hasProofs});

  final String tileId;
  final bool hasProofs;
}
