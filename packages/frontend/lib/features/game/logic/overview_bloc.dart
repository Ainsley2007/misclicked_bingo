import 'dart:developer' as developer;

import 'package:frontend/core/bloc/base_bloc.dart';
import 'package:frontend/repositories/bosses_repository.dart';
import 'package:frontend/repositories/games_repository.dart';
import 'package:frontend/repositories/proofs_repository.dart';
import 'package:frontend/features/game/logic/overview_event.dart';
import 'package:frontend/features/game/logic/overview_state.dart';
import 'package:shared_models/shared_models.dart';

class OverviewBloc extends BaseBloc<OverviewEvent, OverviewState> {
  OverviewBloc(
    this._repository,
    this._bossRepository,
    ProofsRepository proofsRepository,
  ) : super(const OverviewInitial()) {
    on<OverviewLoadRequested>(_onOverviewLoadRequested);
  }

  final GamesRepository _repository;
  final BossesRepository _bossRepository;

  Future<void> _onOverviewLoadRequested(
    OverviewLoadRequested event,
    Emitter<OverviewState> emit,
  ) async {
    emit(const OverviewLoading());
    await execute(
      action: () async {
        final overview = await _repository.getOverview(event.gameId);
        final bosses = await _bossRepository.getBosses();

        final bossesMap = {for (final boss in bosses) boss.id: boss};
        final enrichedTiles = overview.tiles.map((tile) {
          if (tile.isAnyUnique) {
            final boss = bossesMap[tile.bossId];
            if (boss != null) {
              return tile.copyWith(possibleUniqueItems: boss.uniqueItems);
            }
          }
          return tile;
        }).toList();

        final teams = overview.teams.map((team) {
          return TeamOverview(
            id: team.id,
            name: team.name,
            color: team.color,
            boardStates: team.boardStates,
            tilesWithProofs: team.tilesWithProofs,
            teamPoints: team.teamPoints,
          );
        }).toList();

        var loadedState = OverviewLoaded(
          game: overview.game,
          tiles: enrichedTiles,
          teams: teams,
          totalPoints: overview.totalPoints,
          isSidebarLoading: true,
        );
        emit(loadedState);
        developer.log(
          'Loaded overview for game ${overview.game.id}',
          name: 'overview',
        );

        try {
          final results = await Future.wait([
            _repository.getActivity(event.gameId, limit: 20),
            _repository.getStats(event.gameId),
          ]);

          final activities = results[0] as List<TileActivity>;
          final stats = results[1] as ProofStats;

          emit(loadedState.copyWith(
            activities: activities,
            stats: stats,
            isSidebarLoading: false,
          ));
        } catch (e) {
          developer.log(
            'Failed to load activity/stats',
            name: 'overview',
            error: e,
          );
          emit(loadedState.copyWith(isSidebarLoading: false));
        }
      },
      onError: (message) => emit(OverviewError(message)),
      context: 'overview',
      errorMessages: BlocErrorHandlerMixin.gameErrors,
      defaultMessage: 'Failed to load overview',
    );
  }
}
