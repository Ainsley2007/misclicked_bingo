import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/bosses/data/boss_repository.dart';
import 'package:frontend/features/game/data/game_repository.dart';
import 'package:frontend/features/game/logic/game_event.dart';
import 'package:frontend/features/game/logic/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(this._repository, this._bossRepository) : super(const GameInitial()) {
    on<GameLoadRequested>(_onGameLoadRequested);
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

      emit(GameLoaded(game: game, tiles: tiles, bosses: bosses));
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
}
