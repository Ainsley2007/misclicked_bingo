import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/bosses/data/boss_repository.dart';
import 'package:frontend/features/game/data/game_repository.dart';
import 'package:frontend/features/game/logic/game_event.dart';
import 'package:frontend/features/game/logic/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(this._repository, this._bossRepository)
    : super(const GameInitial()) {
    on<GameLoadRequested>(_onGameLoadRequested);
    on<TileCompletionToggled>(_onTileCompletionToggled);
  }

  final GameRepository _repository;
  final BossRepository _bossRepository;

  Future<void> _onGameLoadRequested(
    GameLoadRequested event,
    Emitter<GameState> emit,
  ) async {
    emit(const GameLoading());
    try {
      final game = await _repository.getGame(event.gameId);
      final tiles = await _repository.getTiles(event.gameId);
      final bosses = await _bossRepository.getAllBosses();

      final bossesMap = {for (var boss in bosses) boss.id: boss};
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
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load game',
        name: 'game',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      emit(GameError(e.toString()));
    }
  }

  Future<void> _onTileCompletionToggled(
    TileCompletionToggled event,
    Emitter<GameState> emit,
  ) async {
    final state = this.state;
    if (state is! GameLoaded) return;

    try {
      await _repository.toggleTileCompletion(
        gameId: event.gameId,
        tileId: event.tileId,
      );

      final updatedTiles = state.tiles.map((tile) {
        if (tile.id == event.tileId) {
          return tile.copyWith(isCompleted: !tile.isCompleted);
        }
        return tile;
      }).toList();

      emit(state.copyWith(tiles: updatedTiles, clearError: true));
    } catch (e, stackTrace) {
      developer.log(
        'Failed to toggle tile completion',
        name: 'game',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      // Show error but keep the game loaded
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(actionError: errorMessage));
    }
  }
}
