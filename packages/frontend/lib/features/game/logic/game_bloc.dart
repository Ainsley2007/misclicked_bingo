import 'package:frontend/core/bloc/base_bloc.dart';
import 'package:frontend/repositories/bosses_repository.dart';
import 'package:frontend/repositories/games_repository.dart';
import 'package:frontend/features/game/logic/game_event.dart';
import 'package:frontend/features/game/logic/game_state.dart';

class GameBloc extends BaseBloc<GameEvent, GameState> {
  GameBloc(this._repository, this._bossRepository) : super(const GameInitial()) {
    on<GameLoadRequested>(_onGameLoadRequested);
    onDroppable<TileCompletionToggled>(_onTileCompletionToggled);
  }

  final GamesRepository _repository;
  final BossesRepository _bossRepository;

  Future<void> _onGameLoadRequested(GameLoadRequested event, Emitter<GameState> emit) async {
    emit(const GameLoading());
    await execute(
      action: () async {
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
      },
      onError: (message) => emit(GameError(message)),
      context: 'game',
      errorMessages: BlocErrorHandlerMixin.gameErrors,
      defaultMessage: 'Failed to load game',
    );
  }

  Future<void> _onTileCompletionToggled(TileCompletionToggled event, Emitter<GameState> emit) async {
    final state = this.state;
    if (state is! GameLoaded) return;

    await execute(
      action: () async {
        await _repository.toggleTileCompletion(gameId: event.gameId, tileId: event.tileId);

        final updatedTiles = state.tiles.map((tile) {
          if (tile.id == event.tileId) {
            return tile.copyWith(isCompleted: !tile.isCompleted);
          }
          return tile;
        }).toList();

        emit(state.copyWith(tiles: updatedTiles, clearError: true));
      },
      onError: (message) => emit(state.copyWith(actionError: message)),
      context: 'game',
      errorMessages: {...BlocErrorHandlerMixin.gameErrors, 'NOT_IN_TEAM': 'You must be in a team to complete tiles'},
      defaultMessage: 'Failed to toggle completion',
    );
  }
}
