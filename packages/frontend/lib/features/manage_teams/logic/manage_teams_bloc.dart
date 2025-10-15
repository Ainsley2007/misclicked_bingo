import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/game/data/game_repository.dart';
import 'package:frontend/features/manage_teams/data/teams_repository.dart';
import 'package:frontend/features/manage_teams/logic/manage_teams_event.dart';
import 'package:frontend/features/manage_teams/logic/manage_teams_state.dart';

class ManageTeamsBloc extends Bloc<ManageTeamsEvent, ManageTeamsState> {
  ManageTeamsBloc({
    required TeamsRepository teamsRepository,
    required GameRepository gameRepository,
  }) : _teamsRepository = teamsRepository,
       _gameRepository = gameRepository,
       super(const ManageTeamsState.initial()) {
    on<ManageTeamsLoadRequested>(_onLoadRequested);
    on<ManageTeamsAddMember>(_onAddMember);
    on<ManageTeamsRemoveMember>(_onRemoveMember);
  }

  final TeamsRepository _teamsRepository;
  final GameRepository _gameRepository;

  Future<void> _onLoadRequested(
    ManageTeamsLoadRequested event,
    Emitter<ManageTeamsState> emit,
  ) async {
    emit(ManageTeamsState.loading(teamId: event.teamId, gameId: event.gameId));
    try {
      final team = await _teamsRepository.getTeam(event.teamId);
      final game = await _gameRepository.getGame(event.gameId);
      final teamMembers = await _teamsRepository.getTeamMembers(event.teamId);
      final allUsers = await _gameRepository.getAllUsers();

      final teamMemberIds = teamMembers.map((u) => u.id).toSet();
      final availableUsers = allUsers
          .where((u) => !teamMemberIds.contains(u.id))
          .toList();

      emit(
        ManageTeamsState.loaded(
          teamId: event.teamId,
          gameId: event.gameId,
          teamName: team.name,
          teamSize: game.teamSize,
          teamMembers: teamMembers,
          availableUsers: availableUsers,
        ),
      );
    } catch (e) {
      emit(ManageTeamsState.error(e.toString()));
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
        ManageTeamsState.error('Team is full (${state.teamSize} members max)'),
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
      final availableUsers = allUsers
          .where((u) => !teamMemberIds.contains(u.id))
          .toList();

      emit(
        ManageTeamsState.loaded(
          teamId: state.teamId!,
          gameId: state.gameId!,
          teamName: state.teamName!,
          teamSize: state.teamSize!,
          teamMembers: teamMembers,
          availableUsers: availableUsers,
        ),
      );
    } catch (e) {
      emit(ManageTeamsState.error(e.toString()));
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
      final availableUsers = allUsers
          .where((u) => !teamMemberIds.contains(u.id))
          .toList();

      emit(
        ManageTeamsState.loaded(
          teamId: state.teamId!,
          gameId: state.gameId!,
          teamName: state.teamName!,
          teamSize: state.teamSize!,
          teamMembers: teamMembers,
          availableUsers: availableUsers,
        ),
      );
    } catch (e) {
      emit(ManageTeamsState.error(e.toString()));
    }
  }
}
