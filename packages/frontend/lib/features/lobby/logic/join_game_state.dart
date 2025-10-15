import 'package:equatable/equatable.dart';
import 'package:shared_models/shared_models.dart';

enum JoinGameStatus { initial, loading, success, error }

final class JoinGameState extends Equatable {
  const JoinGameState._({
    required this.status,
    this.game,
    this.team,
    this.errorMessage,
  });

  const JoinGameState.initial() : this._(status: JoinGameStatus.initial);

  const JoinGameState.loading() : this._(status: JoinGameStatus.loading);

  const JoinGameState.success({required Game game, required Team team})
    : this._(status: JoinGameStatus.success, game: game, team: team);

  const JoinGameState.error(String message)
    : this._(status: JoinGameStatus.error, errorMessage: message);

  final JoinGameStatus status;
  final Game? game;
  final Team? team;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, game, team, errorMessage];
}
