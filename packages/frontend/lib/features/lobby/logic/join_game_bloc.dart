import 'package:frontend/core/bloc/base_bloc.dart';
import 'package:frontend/repositories/games_repository.dart';
import 'package:frontend/features/lobby/logic/join_game_event.dart';
import 'package:frontend/features/lobby/logic/join_game_state.dart';

class JoinGameBloc extends BaseBloc<JoinGameEvent, JoinGameState> {
  JoinGameBloc(this._repository) : super(const JoinGameInitial()) {
    onDroppable<JoinGameRequested>(_onJoinGameRequested);
  }

  final GamesRepository _repository;

  Future<void> _onJoinGameRequested(JoinGameRequested event, Emitter<JoinGameState> emit) async {
    emit(const JoinGameLoading());
    await execute(
      action: () async {
        final (game, team) = await _repository.joinGame(code: event.code, teamName: event.teamName);
        emit(JoinGameSuccess(game: game, team: team));
      },
      onError: (message) => emit(JoinGameError(message)),
      context: 'join_game',
      errorMessages: {...BlocErrorHandlerMixin.teamErrors, 'NOT_FOUND': 'Game code not found. Please check the code and try again.'},
      defaultMessage: 'Failed to join game',
    );
  }
}
