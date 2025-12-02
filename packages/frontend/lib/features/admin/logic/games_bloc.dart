import 'package:flutter/foundation.dart';
import 'package:frontend/core/bloc/base_bloc.dart';
import 'package:frontend/repositories/games_repository.dart';
import 'package:shared_models/shared_models.dart';

part 'games_event.dart';
part 'games_state.dart';

class GamesBloc extends BaseBloc<GamesEvent, GamesState> {
  GamesBloc(this._repository) : super(const GamesInitial()) {
    on<GamesLoadRequested>(_onLoadRequested);
    onDroppable<GamesCreateRequested>(_onCreateRequested);
    onDroppable<GamesDeleteRequested>(_onDeleteRequested);
  }

  final GamesRepository _repository;

  Future<void> _onLoadRequested(GamesLoadRequested event, Emitter<GamesState> emit) async {
    emit(const GamesLoading());

    await executeWithResult(
      action: () => _repository.getGames(),
      onSuccess: (games) => emit(GamesLoaded(games)),
      onError: (message) => emit(GamesError(message)),
      context: 'games',
      defaultMessage: 'Failed to load games',
    );
  }

  Future<void> _onCreateRequested(GamesCreateRequested event, Emitter<GamesState> emit) async {
    emit(GamesCreating(state.games));

    await execute(
      action: () async {
        final game = await _repository.createGame(name: event.name, teamSize: event.teamSize, boardSize: 3, gameMode: GameMode.blackout, tiles: []);
        final updatedGames = [game, ...state.games];
        emit(GamesCreated(updatedGames, game));
      },
      onError: (message) => emit(GamesError(message)),
      context: 'games',
      errorMessages: BlocErrorHandlerMixin.validationErrors,
      defaultMessage: 'Failed to create game',
    );
  }

  Future<void> _onDeleteRequested(GamesDeleteRequested event, Emitter<GamesState> emit) async {
    await execute(
      action: () async {
        await _repository.deleteGame(event.gameId);
        final updatedGames = state.games.where((g) => g.id != event.gameId).toList();
        emit(GamesLoaded(updatedGames));
      },
      onError: (message) => emit(GamesError(message)),
      context: 'games',
      defaultMessage: 'Failed to delete game',
    );
  }
}
