import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/bosses_repository.dart';
import 'package:frontend/repositories/games_repository.dart';
import 'package:frontend/repositories/proofs_repository.dart';
import 'package:frontend/core/error/api_exception.dart';
import 'package:frontend/features/game/logic/overview_event.dart';
import 'package:frontend/features/game/logic/overview_state.dart';
import 'package:shared_models/shared_models.dart';

class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  OverviewBloc(this._repository, this._bossRepository, ProofsRepository proofsRepository) : super(const OverviewInitial()) {
    on<OverviewLoadRequested>(_onOverviewLoadRequested);
  }

  final GamesRepository _repository;
  final BossesRepository _bossRepository;

  Future<void> _onOverviewLoadRequested(OverviewLoadRequested event, Emitter<OverviewState> emit) async {
    emit(const OverviewLoading());
    try {
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

      final teams = overview.leaderboard.map((entry) {
        return TeamOverview(id: entry.teamId, name: entry.teamName, color: entry.teamColor ?? '#4CAF50', boardStates: {}, teamPoints: entry.points);
      }).toList();

      final totalPoints = overview.leaderboard.fold<int>(0, (sum, entry) => sum + entry.points);

      var loadedState = OverviewLoaded(game: overview.game, tiles: enrichedTiles, teams: teams, totalPoints: totalPoints);
      emit(loadedState);
      developer.log('Loaded overview for game ${overview.game.id}', name: 'overview');

      try {
        final results = await Future.wait([_repository.getActivity(event.gameId, limit: 20), _repository.getStats(event.gameId)]);

        final activities = results[0] as List<TileActivity>;
        final stats = results[1] as ProofStats;

        emit(loadedState.copyWith(activities: activities, stats: stats));
      } catch (e) {
        developer.log('Failed to load activity/stats', name: 'overview', error: e);
      }
    } on ApiException catch (e) {
      developer.log('Failed to load overview: ${e.code}', name: 'overview', level: 1000);
      emit(OverviewError(e.message));
    } catch (e, stackTrace) {
      developer.log('Failed to load overview', name: 'overview', level: 1000, error: e, stackTrace: stackTrace);
      emit(OverviewError('Failed to load overview: $e'));
    }
  }
}
