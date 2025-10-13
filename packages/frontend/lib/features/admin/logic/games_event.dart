part of 'games_bloc.dart';

sealed class GamesEvent extends Equatable {
  const GamesEvent();

  @override
  List<Object?> get props => [];
}

final class GamesLoadRequested extends GamesEvent {
  const GamesLoadRequested();
}

final class GamesCreateRequested extends GamesEvent {
  const GamesCreateRequested(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class GamesDeleteRequested extends GamesEvent {
  const GamesDeleteRequested(this.gameId);

  final String gameId;

  @override
  List<Object?> get props => [gameId];
}

