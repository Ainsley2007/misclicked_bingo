part of 'games_bloc.dart';

sealed class GamesEvent {
  const GamesEvent();
}

final class GamesLoadRequested extends GamesEvent {
  const GamesLoadRequested();
}

final class GamesCreateRequested extends GamesEvent {
  const GamesCreateRequested(this.name, this.teamSize);

  final String name;
  final int teamSize;
}

final class GamesDeleteRequested extends GamesEvent {
  const GamesDeleteRequested(this.gameId);

  final String gameId;
}
