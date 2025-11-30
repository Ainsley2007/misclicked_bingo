import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/game/data/game_repository.dart';
import 'package:frontend/features/manage_team/data/teams_repository.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_event.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_state.dart';
import 'package:shared_models/shared_models.dart';

class ManageTeamsBloc extends Bloc<ManageTeamsEvent, ManageTeamsState> {
  ManageTeamsBloc({
    required TeamsRepository teamsRepository,
    required GameRepository gameRepository,
  }) : _teamsRepository = teamsRepository,
       _gameRepository = gameRepository,
       super(const ManageTeamsInitial()) {
    on<ManageTeamsLoadRequested>(_onLoadRequested);
    on<ManageTeamsAddMember>(_onAddMember);
    on<ManageTeamsRemoveMember>(_onRemoveMember);
    on<ManageTeamsUpdateColor>(_onUpdateColor);
  }

  final TeamsRepository _teamsRepository;
  final GameRepository _gameRepository;

  Future<void> _onLoadRequested(
    ManageTeamsLoadRequested event,
    Emitter<ManageTeamsState> emit,
  ) async {
    emit(ManageTeamsLoading(teamId: event.teamId, gameId: event.gameId));
    try {
      final team = await _teamsRepository.getTeam(event.teamId);
      final game = await _gameRepository.getGame(event.gameId);
      final teamMembers = await _teamsRepository.getTeamMembers(event.teamId);
      final allUsers = await _gameRepository.getAllUsers();

      final teamMemberIds = teamMembers.map((u) => u.id).toSet();

      // Split users into available and unavailable
      final availableUsers = <AppUser>[];
      final unavailableUsers = <AppUser>[];

      for (final user in allUsers) {
        if (teamMemberIds.contains(user.id)) {
          continue; // Skip current team members
        }
        if (user.teamId == null) {
          availableUsers.add(user);
        } else {
          unavailableUsers.add(user);
        }
      }

      emit(
        ManageTeamsLoaded(
          teamId: event.teamId,
          gameId: event.gameId,
          teamName: team.name,
          teamColor: team.color,
          teamSize: game.teamSize,
          teamMembers: teamMembers,
          availableUsers: availableUsers,
          unavailableUsers: unavailableUsers,
        ),
      );
    } catch (e) {
      emit(ManageTeamsError(e.toString()));
    }
  }

  Future<void> _onUpdateColor(
    ManageTeamsUpdateColor event,
    Emitter<ManageTeamsState> emit,
  ) async {
    if (state.teamId == null) return;

    try {
      await _teamsRepository.updateTeamColor(
        teamId: state.teamId!,
        color: event.color,
      );

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
    } catch (e) {
      emit(ManageTeamsError(e.toString()));
    }
  }

  Future<void> _onAddMember(
    ManageTeamsAddMember event,
    Emitter<ManageTeamsState> emit,
  ) async {
    if (state.teamId == null ||
        state.gameId == null ||
        state.teamName == null ||
        state.teamSize == null)
      return;

    // Check if team is full
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
      await _teamsRepository.addMember(
        teamId: state.teamId!,
        userId: event.userId,
      );

      // Refresh data without showing loading spinner
      final teamMembers = await _teamsRepository.getTeamMembers(state.teamId!);
      final allUsers = await _gameRepository.getAllUsers();

      final teamMemberIds = teamMembers.map((u) => u.id).toSet();

      // Split users into available and unavailable
      final availableUsers = <AppUser>[];
      final unavailableUsers = <AppUser>[];

      for (final user in allUsers) {
        if (teamMemberIds.contains(user.id)) {
          continue; // Skip current team members
        }
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
    } catch (e) {
      emit(ManageTeamsError(e.toString()));
    }
  }

  Future<void> _onRemoveMember(
    ManageTeamsRemoveMember event,
    Emitter<ManageTeamsState> emit,
  ) async {
    if (state.teamId == null ||
        state.gameId == null ||
        state.teamName == null ||
        state.teamSize == null)
      return;

    try {
      await _teamsRepository.removeMember(
        teamId: state.teamId!,
        userId: event.userId,
      );

      // Refresh data without showing loading spinner
      final teamMembers = await _teamsRepository.getTeamMembers(state.teamId!);
      final allUsers = await _gameRepository.getAllUsers();

      final teamMemberIds = teamMembers.map((u) => u.id).toSet();

      // Split users into available and unavailable
      final availableUsers = <AppUser>[];
      final unavailableUsers = <AppUser>[];

      for (final user in allUsers) {
        if (teamMemberIds.contains(user.id)) {
          continue; // Skip current team members
        }
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
    } catch (e) {
      emit(ManageTeamsError(e.toString()));
    }
  }
}
