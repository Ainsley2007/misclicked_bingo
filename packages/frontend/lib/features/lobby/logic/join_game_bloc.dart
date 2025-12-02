import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/games_repository.dart';
import 'package:frontend/core/error/api_exception.dart';
import 'package:frontend/features/lobby/logic/join_game_event.dart';
import 'package:frontend/features/lobby/logic/join_game_state.dart';

class JoinGameBloc extends Bloc<JoinGameEvent, JoinGameState> {
  JoinGameBloc(this._repository) : super(const JoinGameInitial()) {
    on<JoinGameRequested>(_onJoinGameRequested);
  }

  final GamesRepository _repository;

  Future<void> _onJoinGameRequested(JoinGameRequested event, Emitter<JoinGameState> emit) async {
    emit(const JoinGameLoading());
    try {
      final (game, team) = await _repository.joinGame(code: event.code, teamName: event.teamName);
      emit(JoinGameSuccess(game: game, team: team));
      developer.log('Joined game ${game.code} with team ${team.name}', name: 'join_game');
    } on ApiException catch (e) {
      developer.log('Failed to join game: ${e.code}', name: 'join_game', level: 1000);
      final message = switch (e.code) {
        'NOT_FOUND' => 'Game code not found. Please check the code and try again.',
        'TEAM_FULL' => 'This team is already full.',
        'ALREADY_IN_TEAM' => 'You are already in a team for this game.',
        _ => e.message,
      };
      emit(JoinGameError(message));
    } catch (e, stackTrace) {
      developer.log('Failed to join game', name: 'join_game', level: 1000, error: e, stackTrace: stackTrace);
      emit(JoinGameError('Failed to join game: $e'));
    }
  }
}
