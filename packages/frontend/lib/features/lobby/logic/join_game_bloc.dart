import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/lobby/data/lobby_repository.dart';
import 'package:frontend/features/lobby/logic/join_game_event.dart';
import 'package:frontend/features/lobby/logic/join_game_state.dart';

class JoinGameBloc extends Bloc<JoinGameEvent, JoinGameState> {
  JoinGameBloc(this._repository) : super(const JoinGameInitial()) {
    on<JoinGameRequested>(_onJoinGameRequested);
  }

  final LobbyRepository _repository;

  Future<void> _onJoinGameRequested(JoinGameRequested event, Emitter<JoinGameState> emit) async {
    emit(const JoinGameLoading());
    try {
      final (game, team) = await _repository.joinGame(code: event.code, teamName: event.teamName);
      emit(JoinGameSuccess(game: game, team: team));
      developer.log('Joined game ${game.code} with team ${team.name}', name: 'join_game');
    } catch (e, stackTrace) {
      developer.log('Failed to join game', name: 'join_game', level: 1000, error: e, stackTrace: stackTrace);
      emit(JoinGameError(e.toString()));
    }
  }
}
