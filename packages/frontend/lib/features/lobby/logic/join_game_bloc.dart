import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/lobby/data/lobby_repository.dart';
import 'package:frontend/features/lobby/logic/join_game_event.dart';
import 'package:frontend/features/lobby/logic/join_game_state.dart';

class JoinGameBloc extends Bloc<JoinGameEvent, JoinGameState> {
  JoinGameBloc(this._repository) : super(const JoinGameState.initial()) {
    on<JoinGameRequested>(_onJoinGameRequested);
  }

  final LobbyRepository _repository;

  Future<void> _onJoinGameRequested(
    JoinGameRequested event,
    Emitter<JoinGameState> emit,
  ) async {
    emit(const JoinGameState.loading());
    try {
      final (game, team) = await _repository.joinGame(
        code: event.code,
        teamName: event.teamName,
      );
      emit(JoinGameState.success(game: game, team: team));
    } catch (e) {
      emit(JoinGameState.error(e.toString()));
    }
  }
}
