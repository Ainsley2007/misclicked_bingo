import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/game/data/game_repository.dart';
import 'package:frontend/features/game/logic/game_event.dart';
import 'package:frontend/features/game/logic/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(this._repository) : super(const GameState.initial()) {
    on<GameLoadRequested>(_onGameLoadRequested);
  }

  final GameRepository _repository;

  Future<void> _onGameLoadRequested(
    GameLoadRequested event,
    Emitter<GameState> emit,
  ) async {
    emit(const GameState.loading());
    try {
      final users = await _repository.getGameUsers(event.gameId);
      emit(GameState.loaded(users));
    } catch (e) {
      emit(GameState.error(e.toString()));
    }
  }
}
