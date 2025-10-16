import 'package:equatable/equatable.dart';
import 'package:shared_models/shared_models.dart';

enum GameStatus { initial, loading, loaded, error }

final class GameState extends Equatable {
  const GameState._({
    required this.status,
    this.game,
    this.challenges = const [],
    this.tiles = const [],
    this.users = const [],
    this.errorMessage,
  });

  const GameState.initial() : this._(status: GameStatus.initial);

  const GameState.loading() : this._(status: GameStatus.loading);

  const GameState.loaded({
    required Game game,
    required List<Challenge> challenges,
    required List<BingoTile> tiles,
    List<AppUser> users = const [],
  }) : this._(
         status: GameStatus.loaded,
         game: game,
         challenges: challenges,
         tiles: tiles,
         users: users,
       );

  const GameState.error(String message)
    : this._(status: GameStatus.error, errorMessage: message);

  final GameStatus status;
  final Game? game;
  final List<Challenge> challenges;
  final List<BingoTile> tiles;
  final List<AppUser> users;
  final String? errorMessage;

  @override
  List<Object?> get props => [
    status,
    game,
    challenges,
    tiles,
    users,
    errorMessage,
  ];
}
