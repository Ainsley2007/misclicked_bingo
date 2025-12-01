import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/bosses/data/boss_repository.dart';
import 'package:frontend/features/game/data/game_repository.dart';
import 'package:frontend/features/game/data/proofs_repository.dart';
import 'package:frontend/features/game/logic/overview_event.dart';
import 'package:frontend/features/game/logic/overview_state.dart';
import 'package:shared_models/shared_models.dart';

class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  OverviewBloc(this._repository, this._bossRepository, this._proofsRepository)
    : super(const OverviewInitial()) {
    on<OverviewLoadRequested>(_onOverviewLoadRequested);
  }

  final GameRepository _repository;
  final BossRepository _bossRepository;
  final ProofsRepository _proofsRepository;

  Future<void> _onOverviewLoadRequested(
    OverviewLoadRequested event,
    Emitter<OverviewState> emit,
  ) async {
    emit(const OverviewLoading());
    try {
      final data = await _repository.getOverview(event.gameId);
      final game = Game.fromJson(data['game'] as Map<String, dynamic>);
      final tilesJson = data['tiles'] as List<dynamic>;
      final teamsJson = data['teams'] as List<dynamic>;

      final tiles = tilesJson
          .map((json) => BingoTile.fromJson(json as Map<String, dynamic>))
          .toList();

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

      final teams = teamsJson.map((json) {
        final teamData = json as Map<String, dynamic>;
        final tilesWithProofsJson = teamData['tilesWithProofs'] as List<dynamic>?;
        return TeamOverview(
          id: teamData['id'] as String,
          name: teamData['name'] as String,
          color: teamData['color'] as String? ?? '#4CAF50',
          boardStates: Map<String, String>.from(
            teamData['boardStates'] as Map<String, dynamic>,
          ),
          tilesWithProofs: tilesWithProofsJson?.cast<String>() ?? [],
          teamPoints: (teamData['teamPoints'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      final totalPoints = (data['totalPoints'] as num?)?.toInt() ?? 0;

      var loadedState = OverviewLoaded(
        game: game,
        tiles: enrichedTiles,
        teams: teams,
        totalPoints: totalPoints,
      );
      emit(loadedState);
      developer.log('Loaded overview for game ${game.id}', name: 'overview');

      try {
        final results = await Future.wait([
          _proofsRepository.getActivity(gameId: event.gameId, limit: 20),
          _proofsRepository.getStats(gameId: event.gameId),
        ]);

        final activities = results[0] as List<TileActivity>;
        final stats = results[1] as ProofStats;

        emit(loadedState.copyWith(activities: activities, stats: stats));
      } catch (e) {
        developer.log(
          'Failed to load activity/stats',
          name: 'overview',
          error: e,
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Failed to load overview',
        name: 'overview',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      emit(OverviewError(e.toString()));
    }
  }
}
