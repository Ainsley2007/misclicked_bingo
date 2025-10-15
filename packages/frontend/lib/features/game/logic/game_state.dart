import 'package:equatable/equatable.dart';
import 'package:shared_models/shared_models.dart';

enum GameStatus { initial, loading, loaded, error }

final class GameState extends Equatable {
  const GameState._({
    required this.status,
    this.users = const [],
    this.errorMessage,
  });

  const GameState.initial() : this._(status: GameStatus.initial);

  const GameState.loading() : this._(status: GameStatus.loading);

  const GameState.loaded(List<AppUser> users)
    : this._(status: GameStatus.loaded, users: users);

  const GameState.error(String message)
    : this._(status: GameStatus.error, errorMessage: message);

  final GameStatus status;
  final List<AppUser> users;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, users, errorMessage];
}
