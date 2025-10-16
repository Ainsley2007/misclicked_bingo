part of 'games_bloc.dart';

@immutable
sealed class GamesState {
  const GamesState();
  List<Game> get games => const [];
}

@immutable
final class GamesInitial extends GamesState {
  const GamesInitial();
}

@immutable
final class GamesLoading extends GamesState {
  const GamesLoading();
}

@immutable
final class GamesLoaded extends GamesState {
  const GamesLoaded(this._games);
  final List<Game> _games;

  @override
  List<Game> get games => _games;
}

@immutable
final class GamesCreating extends GamesState {
  const GamesCreating(this._games);
  final List<Game> _games;

  @override
  List<Game> get games => _games;
}

@immutable
final class GamesCreated extends GamesState {
  const GamesCreated(this._games, this.createdGame);
  final List<Game> _games;
  final Game createdGame;

  @override
  List<Game> get games => _games;
}

@immutable
final class GamesError extends GamesState {
  const GamesError(this.message);
  final String message;
}
