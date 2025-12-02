import 'dart:developer' as developer;

import 'package:frontend/core/bloc/base_bloc.dart';
import 'package:frontend/repositories/games_repository.dart';
import 'package:frontend/features/guest/logic/guest_event.dart';
import 'package:frontend/features/guest/logic/guest_state.dart';
import 'package:shared_models/shared_models.dart';

class GuestBloc extends BaseBloc<GuestEvent, GuestState> {
  GuestBloc(this._repository) : super(const GuestInitial()) {
    on<GuestGamesLoadRequested>(_onGamesLoadRequested);
    on<GuestGameOverviewLoadRequested>(_onGameOverviewLoadRequested);
  }

  final GamesRepository _repository;

  Future<void> _onGamesLoadRequested(GuestGamesLoadRequested event, Emitter<GuestState> emit) async {
    emit(const GuestLoading());
    await executeWithResult(
      action: () => _repository.getPublicGames(),
      onSuccess: (games) {
        emit(GuestGamesLoaded(games));
        developer.log('Loaded ${games.length} public games', name: 'guest');
      },
      onError: (message) => emit(GuestError(message)),
      context: 'guest',
      defaultMessage: 'Failed to load games',
    );
  }

  Future<void> _onGameOverviewLoadRequested(GuestGameOverviewLoadRequested event, Emitter<GuestState> emit) async {
    emit(const GuestLoading());
    await executeWithResult(
      action: () => _repository.getPublicOverview(event.gameId),
      onSuccess: (overview) async {
        final teams = overview.leaderboard.map((entry) {
          return GuestTeamOverview(id: entry.teamId, name: entry.teamName, color: entry.teamColor ?? '#4CAF50', boardStates: {});
        }).toList();

        var loadedState = GuestGameOverviewLoaded(game: overview.game, tiles: overview.tiles, teams: teams);
        emit(loadedState);
        developer.log('Loaded public overview for game ${overview.game.id}', name: 'guest');

        try {
          final results = await Future.wait([_repository.getPublicActivity(event.gameId, limit: 20), _repository.getPublicStats(event.gameId)]);

          emit(GuestGameOverviewLoaded(game: overview.game, tiles: overview.tiles, teams: teams, activities: results[0] as List<TileActivity>, stats: results[1] as ProofStats));
        } catch (e) {
          developer.log('Failed to load activity/stats', name: 'guest', error: e);
        }
      },
      onError: (message) => emit(GuestError(message)),
      context: 'guest',
      defaultMessage: 'Failed to load game overview',
    );
  }
}
