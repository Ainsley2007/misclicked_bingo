part of 'games_bloc.dart';

enum GamesStatus { initial, loading, loaded, creating, created, error }

final class GamesState extends Equatable {
  const GamesState._({
    required this.status,
    this.games = const [],
    this.createdGame,
    this.error,
  });

  const GamesState.initial() : this._(status: GamesStatus.initial);
  
  const GamesState.loading() : this._(status: GamesStatus.loading);
  
  const GamesState.loaded(List<Game> games) : this._(status: GamesStatus.loaded, games: games);
  
  const GamesState.creating(List<Game> games) : this._(status: GamesStatus.creating, games: games);
  
  const GamesState.created(List<Game> games, Game createdGame) : this._(status: GamesStatus.created, games: games, createdGame: createdGame);
  
  const GamesState.error(String error) : this._(status: GamesStatus.error, error: error);

  final GamesStatus status;
  final List<Game> games;
  final Game? createdGame;
  final String? error;

  @override
  List<Object?> get props => [status, games, createdGame, error];
}

