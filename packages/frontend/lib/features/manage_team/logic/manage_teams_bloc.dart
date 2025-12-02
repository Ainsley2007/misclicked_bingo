import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/games_repository.dart';
import 'package:frontend/repositories/teams_repository.dart';
import 'package:frontend/core/error/api_exception.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_event.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_state.dart';
import 'package:shared_models/shared_models.dart';

class ManageTeamsBloc extends Bloc<ManageTeamsEvent, ManageTeamsState> {
  ManageTeamsBloc({required TeamsRepository teamsRepository, required GamesRepository gamesRepository})
    : _teamsRepository = teamsRepository,
      _gamesRepository = gamesRepository,
      super(const ManageTeamsInitial()) {
    on<ManageTeamsLoadRequested>(_onLoadRequested);
    on<ManageTeamsAddMember>(_onAddMember);
    on<ManageTeamsRemoveMember>(_onRemoveMember);
    on<ManageTeamsUpdateColor>(_onUpdateColor);
  }

  final TeamsRepository _teamsRepository;
  final GamesRepository _gamesRepository;

  Future<void> _onLoadRequested(ManageTeamsLoadRequested event, Emitter<ManageTeamsState> emit) async {
    emit(ManageTeamsLoading(teamId: event.teamId, gameId: event.gameId));
    try {
      final teamMembers = await _teamsRepository.getTeamMembers(event.teamId);
      final game = await _gamesRepository.getGame(event.gameId);
      final allUsers = await _gamesRepository.getGameUsers(event.gameId);

      final teamMemberIds = teamMembers.map((u) => u.id).toSet();

      final availableUsers = <AppUser>[];
      final unavailableUsers = <AppUser>[];

      for (final user in allUsers) {
        if (teamMemberIds.contains(user.id)) continue;
        if (user.teamId == null) {
          availableUsers.add(user);
        } else {
          unavailableUsers.add(user);
        }
      }

      final teamName = teamMembers.isNotEmpty ? 'Team' : 'Team';

      emit(
        ManageTeamsLoaded(
          teamId: event.teamId,
          gameId: event.gameId,
          teamName: teamName,
          teamColor: '#4CAF50',
          teamSize: game.teamSize,
          teamMembers: teamMembers,
          availableUsers: availableUsers,
          unavailableUsers: unavailableUsers,
        ),
      );
      developer.log('Loaded team ${event.teamId}', name: 'manage_teams');
    } on ApiException catch (e) {
      developer.log('Failed to load team: ${e.code}', name: 'manage_teams', level: 1000);
      emit(ManageTeamsError(e.message));
    } catch (e, stackTrace) {
      developer.log('Failed to load team', name: 'manage_teams', level: 1000, error: e, stackTrace: stackTrace);
      emit(ManageTeamsError('Failed to load team: $e'));
    }
  }

  Future<void> _onUpdateColor(ManageTeamsUpdateColor event, Emitter<ManageTeamsState> emit) async {
    if (state.teamId == null) return;

    try {
      await _teamsRepository.updateTeamColor(teamId: state.teamId!, color: event.color);

      if (state is ManageTeamsLoaded) {
        final loaded = state as ManageTeamsLoaded;
        emit(
          ManageTeamsLoaded(
            teamId: loaded.teamId,
            gameId: loaded.gameId,
            teamName: loaded.teamName,
            teamColor: event.color,
            teamSize: loaded.teamSize,
            teamMembers: loaded.teamMembers,
            availableUsers: loaded.availableUsers,
            unavailableUsers: loaded.unavailableUsers,
          ),
        );
      }
    } on ApiException catch (e) {
      developer.log('Failed to update color: ${e.code}', name: 'manage_teams', level: 1000);
      emit(ManageTeamsError(e.message));
    } catch (e) {
      emit(ManageTeamsError('Failed to update color: $e'));
    }
  }

  Future<void> _onAddMember(ManageTeamsAddMember event, Emitter<ManageTeamsState> emit) async {
    if (state.teamId == null || state.gameId == null || state.teamName == null || state.teamSize == null) {
      return;
    }

    if (state.teamMembers.length >= state.teamSize!) {
      emit(
        ManageTeamsLoaded(
          teamId: state.teamId!,
          gameId: state.gameId!,
          teamName: state.teamName!,
          teamColor: state.teamColor ?? '#4CAF50',
          teamSize: state.teamSize!,
          teamMembers: state.teamMembers,
          availableUsers: state.availableUsers,
          unavailableUsers: state.unavailableUsers,
          message: 'Team is full (${state.teamSize} members max)',
        ),
      );
      return;
    }

    try {
      await _teamsRepository.addMember(teamId: state.teamId!, userId: event.userId);

      final teamMembers = await _teamsRepository.getTeamMembers(state.teamId!);
      final allUsers = await _gamesRepository.getGameUsers(state.gameId!);

      final teamMemberIds = teamMembers.map((u) => u.id).toSet();

      final availableUsers = <AppUser>[];
      final unavailableUsers = <AppUser>[];

      for (final user in allUsers) {
        if (teamMemberIds.contains(user.id)) continue;
        if (user.teamId == null) {
          availableUsers.add(user);
        } else {
          unavailableUsers.add(user);
        }
      }

      emit(
        ManageTeamsLoaded(
          teamId: state.teamId!,
          gameId: state.gameId!,
          teamName: state.teamName!,
          teamColor: state.teamColor ?? '#4CAF50',
          teamSize: state.teamSize!,
          teamMembers: teamMembers,
          availableUsers: availableUsers,
          unavailableUsers: unavailableUsers,
        ),
      );
    } on ApiException catch (e) {
      developer.log('Failed to add member: ${e.code}', name: 'manage_teams', level: 1000);
      final message = switch (e.code) {
        'TEAM_FULL' => 'Team is full',
        'ALREADY_IN_TEAM' => 'User is already in a team',
        _ => e.message,
      };
      emit(ManageTeamsError(message));
    } catch (e) {
      emit(ManageTeamsError('Failed to add member: $e'));
    }
  }

  Future<void> _onRemoveMember(ManageTeamsRemoveMember event, Emitter<ManageTeamsState> emit) async {
    if (state.teamId == null || state.gameId == null || state.teamName == null || state.teamSize == null) {
      return;
    }

    try {
      await _teamsRepository.removeMember(teamId: state.teamId!, userId: event.userId);

      final teamMembers = await _teamsRepository.getTeamMembers(state.teamId!);
      final allUsers = await _gamesRepository.getGameUsers(state.gameId!);

      final teamMemberIds = teamMembers.map((u) => u.id).toSet();

      final availableUsers = <AppUser>[];
      final unavailableUsers = <AppUser>[];

      for (final user in allUsers) {
        if (teamMemberIds.contains(user.id)) continue;
        if (user.teamId == null) {
          availableUsers.add(user);
        } else {
          unavailableUsers.add(user);
        }
      }

      emit(
        ManageTeamsLoaded(
          teamId: state.teamId!,
          gameId: state.gameId!,
          teamName: state.teamName!,
          teamColor: state.teamColor ?? '#4CAF50',
          teamSize: state.teamSize!,
          teamMembers: teamMembers,
          availableUsers: availableUsers,
          unavailableUsers: unavailableUsers,
        ),
      );
    } on ApiException catch (e) {
      developer.log('Failed to remove member: ${e.code}', name: 'manage_teams', level: 1000);
      emit(ManageTeamsError(e.message));
    } catch (e) {
      emit(ManageTeamsError('Failed to remove member: $e'));
    }
  }
}
