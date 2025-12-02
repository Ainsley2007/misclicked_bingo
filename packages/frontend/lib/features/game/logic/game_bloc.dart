import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/bosses_repository.dart';
import 'package:frontend/repositories/games_repository.dart';
import 'package:frontend/core/error/api_exception.dart';
import 'package:frontend/features/game/logic/game_event.dart';
import 'package:frontend/features/game/logic/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(this._repository, this._bossRepository) : super(const GameInitial()) {
    on<GameLoadRequested>(_onGameLoadRequested);
    on<TileCompletionToggled>(_onTileCompletionToggled);
  }

  final GamesRepository _repository;
  final BossesRepository _bossRepository;

  Future<void> _onGameLoadRequested(GameLoadRequested event, Emitter<GameState> emit) async {
    emit(const GameLoading());
    try {
      final game = await _repository.getGame(event.gameId);
      final tiles = await _repository.getTiles(event.gameId);
      final bosses = await _bossRepository.getBosses();

      final bossesMap = {for (final boss in bosses) boss.id: boss};
      final enrichedTiles = tiles.map((tile) {
        if (tile.isAnyUnique) {
          final boss = bossesMap[tile.bossId];
          if (boss != null) {
            return tile.copyWith(possibleUniqueItems: boss.uniqueItems);
          }
        }
        return tile;
      }).toList();

      emit(GameLoaded(game: game, tiles: enrichedTiles));
      developer.log('Loaded game ${game.id}', name: 'game');
    } on ApiException catch (e) {
      developer.log('Failed to load game: ${e.code}', name: 'game', level: 1000);
      emit(GameError(e.message));
    } catch (e, stackTrace) {
      developer.log('Failed to load game', name: 'game', level: 1000, error: e, stackTrace: stackTrace);
      emit(GameError('Failed to load game: $e'));
    }
  }

  Future<void> _onTileCompletionToggled(TileCompletionToggled event, Emitter<GameState> emit) async {
    final state = this.state;
    if (state is! GameLoaded) return;

    try {
      await _repository.toggleTileCompletion(gameId: event.gameId, tileId: event.tileId);

      final updatedTiles = state.tiles.map((tile) {
        if (tile.id == event.tileId) {
          return tile.copyWith(isCompleted: !tile.isCompleted);
        }
        return tile;
      }).toList();

      emit(state.copyWith(tiles: updatedTiles, clearError: true));
    } on ApiException catch (e) {
      developer.log('Failed to toggle tile completion: ${e.code}', name: 'game', level: 1000);
      final message = switch (e.code) {
        'GAME_NOT_STARTED' => 'Game has not started yet',
        'GAME_ENDED' => 'Game has already ended',
        'NOT_IN_TEAM' => 'You must be in a team to complete tiles',
        _ => e.message,
      };
      emit(state.copyWith(actionError: message));
    } catch (e, stackTrace) {
      developer.log('Failed to toggle tile completion', name: 'game', level: 1000, error: e, stackTrace: stackTrace);
      emit(state.copyWith(actionError: 'Failed to toggle completion'));
    }
  }
}
