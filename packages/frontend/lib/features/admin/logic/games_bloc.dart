import 'dart:developer' as developer;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';
import 'package:frontend/features/admin/data/games_repository.dart';

part 'games_event.dart';
part 'games_state.dart';

class GamesBloc extends Bloc<GamesEvent, GamesState> {
  GamesBloc(this._repository) : super(const GamesState.initial()) {
    on<GamesLoadRequested>(_onLoadRequested);
    on<GamesCreateRequested>(_onCreateRequested);
    on<GamesDeleteRequested>(_onDeleteRequested);
  }

  final GamesRepository _repository;

  Future<void> _onLoadRequested(
    GamesLoadRequested event,
    Emitter<GamesState> emit,
  ) async {
    emit(const GamesState.loading());

    try {
      final games = await _repository.getGames();
      emit(GamesState.loaded(games));
      developer.log('Loaded ${games.length} games', name: 'games');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load games',
        name: 'games',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      emit(GamesState.error('Failed to load games: $e'));
    }
  }

  Future<void> _onCreateRequested(
    GamesCreateRequested event,
    Emitter<GamesState> emit,
  ) async {
    emit(GamesState.creating(state.games));

    try {
      final game = await _repository.createGame(event.name, event.teamSize);
      final updatedGames = [game, ...state.games];
      emit(GamesState.created(updatedGames, game));
      developer.log('Created game: ${game.name} (${game.code})', name: 'games');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to create game',
        name: 'games',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      emit(GamesState.error('Failed to create game: $e'));
    }
  }

  Future<void> _onDeleteRequested(
    GamesDeleteRequested event,
    Emitter<GamesState> emit,
  ) async {
    try {
      await _repository.deleteGame(event.gameId);
      final updatedGames = state.games
          .where((g) => g.id != event.gameId)
          .toList();
      emit(GamesState.loaded(updatedGames));
      developer.log('Deleted game: ${event.gameId}', name: 'games');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete game',
        name: 'games',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      emit(GamesState.error('Failed to delete game: $e'));
    }
  }
}
