import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/guest/data/guest_repository.dart';
import 'package:frontend/features/guest/logic/guest_event.dart';
import 'package:frontend/features/guest/logic/guest_state.dart';
import 'package:shared_models/shared_models.dart';

class GuestBloc extends Bloc<GuestEvent, GuestState> {
  GuestBloc(this._repository) : super(const GuestInitial()) {
    on<GuestGamesLoadRequested>(_onGamesLoadRequested);
    on<GuestGameOverviewLoadRequested>(_onGameOverviewLoadRequested);
  }

  final GuestRepository _repository;

  Future<void> _onGamesLoadRequested(
    GuestGamesLoadRequested event,
    Emitter<GuestState> emit,
  ) async {
    emit(const GuestLoading());
    try {
      final games = await _repository.getPublicGames();
      emit(GuestGamesLoaded(games));
    } catch (e) {
      developer.log('Failed to load games', name: 'guest', error: e);
      emit(GuestError(e.toString()));
    }
  }

  Future<void> _onGameOverviewLoadRequested(
    GuestGameOverviewLoadRequested event,
    Emitter<GuestState> emit,
  ) async {
    emit(const GuestLoading());
    try {
      final data = await _repository.getPublicGameOverview(event.gameId);
      final game = Game.fromJson(data['game'] as Map<String, dynamic>);
      final tilesJson = data['tiles'] as List<dynamic>;
      final teamsJson = data['teams'] as List<dynamic>;

      final tiles = tilesJson
          .map((json) => BingoTile.fromJson(json as Map<String, dynamic>))
          .toList();

      final teams = teamsJson.map((json) {
        final teamData = json as Map<String, dynamic>;
        return GuestTeamOverview(
          id: teamData['id'] as String,
          name: teamData['name'] as String,
          color: teamData['color'] as String? ?? '#4CAF50',
          boardStates: Map<String, String>.from(
            teamData['boardStates'] as Map<String, dynamic>,
          ),
        );
      }).toList();

      var loadedState = GuestGameOverviewLoaded(
        game: game,
        tiles: tiles,
        teams: teams,
      );
      emit(loadedState);

      try {
        final results = await Future.wait([
          _repository.getPublicActivity(gameId: event.gameId, limit: 20),
          _repository.getPublicStats(gameId: event.gameId),
        ]);

        final activities = results[0] as List<TileActivity>;
        final stats = results[1] as ProofStats;

        emit(GuestGameOverviewLoaded(
          game: game,
          tiles: tiles,
          teams: teams,
          activities: activities,
          stats: stats,
        ));
      } catch (e) {
        developer.log(
          'Failed to load activity/stats',
          name: 'guest',
          error: e,
        );
      }
    } catch (e) {
      developer.log('Failed to load game overview', name: 'guest', error: e);
      emit(GuestError(e.toString()));
    }
  }
}

