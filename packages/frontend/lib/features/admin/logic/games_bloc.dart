import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';
import 'package:frontend/features/admin/data/games_repository.dart';

part 'games_event.dart';
part 'games_state.dart';

class GamesBloc extends Bloc<GamesEvent, GamesState> {
  GamesBloc(this._repository) : super(const GamesInitial()) {
    on<GamesLoadRequested>(_onLoadRequested);
    on<GamesCreateRequested>(_onCreateRequested);
    on<GamesDeleteRequested>(_onDeleteRequested);
  }

  final GamesRepository _repository;

  Future<void> _onLoadRequested(GamesLoadRequested event, Emitter<GamesState> emit) async {
    emit(const GamesLoading());

    try {
      final games = await _repository.getGames();
      emit(GamesLoaded(games));
      developer.log('Loaded ${games.length} games', name: 'games');
    } catch (e, stackTrace) {
      developer.log('Failed to load games', name: 'games', level: 1000, error: e, stackTrace: stackTrace);
      emit(GamesError('Failed to load games: $e'));
    }
  }

  Future<void> _onCreateRequested(GamesCreateRequested event, Emitter<GamesState> emit) async {
    emit(GamesCreating(state.games));

    try {
      final game = await _repository.createGame(event.name, event.teamSize);
      final updatedGames = [game, ...state.games];
      emit(GamesCreated(updatedGames, game));
      developer.log('Created game: ${game.name} (${game.code})', name: 'games');
    } catch (e, stackTrace) {
      developer.log('Failed to create game', name: 'games', level: 1000, error: e, stackTrace: stackTrace);
      emit(GamesError('Failed to create game: $e'));
    }
  }

  Future<void> _onDeleteRequested(GamesDeleteRequested event, Emitter<GamesState> emit) async {
    try {
      await _repository.deleteGame(event.gameId);
      final updatedGames = state.games.where((g) => g.id != event.gameId).toList();
      emit(GamesLoaded(updatedGames));
      developer.log('Deleted game: ${event.gameId}', name: 'games');
    } catch (e, stackTrace) {
      developer.log('Failed to delete game', name: 'games', level: 1000, error: e, stackTrace: stackTrace);
      emit(GamesError('Failed to delete game: $e'));
    }
  }
}
