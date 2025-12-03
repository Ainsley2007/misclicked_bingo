import 'dart:developer' as developer;

import 'package:frontend/core/bloc/base_bloc.dart';
import 'package:frontend/repositories/games_repository.dart';
import 'package:frontend/repositories/teams_repository.dart';
import 'package:frontend/repositories/users_repository.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_event.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_state.dart';
import 'package:shared_models/shared_models.dart';

class ManageTeamsBloc extends BaseBloc<ManageTeamsEvent, ManageTeamsState> {
  ManageTeamsBloc({
    required TeamsRepository teamsRepository,
    required GamesRepository gamesRepository,
    required UsersRepository usersRepository,
  }) : _teamsRepository = teamsRepository,
       _gamesRepository = gamesRepository,
       _usersRepository = usersRepository,
       super(const ManageTeamsInitial()) {
    on<ManageTeamsLoadRequested>(_onLoadRequested);
    on<ManageTeamsRefreshUsers>(_onRefreshUsers);
    onDroppable<ManageTeamsAddMember>(_onAddMember);
    onDroppable<ManageTeamsRemoveMember>(_onRemoveMember);
    onDroppable<ManageTeamsUpdateColor>(_onUpdateColor);
  }

  final TeamsRepository _teamsRepository;
  final GamesRepository _gamesRepository;
  final UsersRepository _usersRepository;

  Future<void> _onLoadRequested(
    ManageTeamsLoadRequested event,
    Emitter<ManageTeamsState> emit,
  ) async {
    emit(ManageTeamsLoading(teamId: event.teamId, gameId: event.gameId));
    await execute(
      action: () async {
        final results = await Future.wait([
          _teamsRepository.getTeamMembers(event.teamId),
          _gamesRepository.getGame(event.gameId),
        ]);
        final teamMembers = results[0] as List<AppUser>;
        final game = results[1] as Game;

        final teamName = teamMembers.isNotEmpty ? 'Team' : 'Team';

        var loadedState = ManageTeamsLoaded(
          teamId: event.teamId,
          gameId: event.gameId,
          teamName: teamName,
          teamColor: '#4CAF50',
          teamSize: game.teamSize,
          teamMembers: teamMembers,
          isUsersLoading: true,
        );
        emit(loadedState);
        developer.log('Loaded team ${event.teamId}', name: 'manage_teams');

        try {
          final allUsers = await _usersRepository.getUsers();
          final teamMemberIds = teamMembers.map((u) => u.id).toSet();

          final availableUsers = <AppUser>[];
          final unavailableUsers = <AppUser>[];

          for (final user in allUsers) {
            if (teamMemberIds.contains(user.id)) continue;
            // Available: users not in any game, or in this game but no team
            if (user.gameId == null ||
                (user.gameId == event.gameId && user.teamId == null)) {
              availableUsers.add(user);
            } else if (user.gameId != event.gameId) {
              // Unavailable: users in a different game
              unavailableUsers.add(user);
            }
            // Users in this game but on another team are handled by the team members check
          }

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
              isUsersLoading: false,
            ),
          );
        } catch (e) {
          developer.log(
            'Failed to load game users',
            name: 'manage_teams',
            error: e,
          );
          emit(
            ManageTeamsLoaded(
              teamId: event.teamId,
              gameId: event.gameId,
              teamName: teamName,
              teamColor: '#4CAF50',
              teamSize: game.teamSize,
              teamMembers: teamMembers,
              isUsersLoading: false,
            ),
          );
        }
      },
      onError: (message) => emit(ManageTeamsError(message)),
      context: 'manage_teams',
      defaultMessage: 'Failed to load team',
    );
  }

  Future<void> _onRefreshUsers(
    ManageTeamsRefreshUsers event,
    Emitter<ManageTeamsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ManageTeamsLoaded) return;

    // Set users loading without triggering full page reload
    emit(currentState.copyWith(isUsersLoading: true));

    await execute(
      action: () async {
        final results = await Future.wait([
          _teamsRepository.getTeamMembers(currentState.teamId),
          _usersRepository.getUsers(),
        ]);

        final teamMembers = results[0];
        final allUsers = results[1];
        final teamMemberIds = teamMembers.map((u) => u.id).toSet();

        final availableUsers = <AppUser>[];
        final unavailableUsers = <AppUser>[];

        for (final user in allUsers) {
          if (teamMemberIds.contains(user.id)) continue;
          if (user.gameId == null ||
              (user.gameId == currentState.gameId && user.teamId == null)) {
            availableUsers.add(user);
          } else if (user.gameId != currentState.gameId) {
            unavailableUsers.add(user);
          }
        }

        emit(
          currentState.copyWith(
            teamMembers: teamMembers,
            availableUsers: availableUsers,
            unavailableUsers: unavailableUsers,
            isUsersLoading: false,
          ),
        );
      },
      onError: (message) =>
          emit(currentState.copyWith(isUsersLoading: false, message: message)),
      context: 'manage_teams',
      defaultMessage: 'Failed to refresh users',
    );
  }

  Future<void> _onUpdateColor(
    ManageTeamsUpdateColor event,
    Emitter<ManageTeamsState> emit,
  ) async {
    if (state.teamId == null) return;

    await execute(
      action: () async {
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
      },
      onError: (message) => emit(ManageTeamsError(message)),
      context: 'manage_teams',
      defaultMessage: 'Failed to update color',
    );
  }

  Future<void> _onAddMember(
    ManageTeamsAddMember event,
    Emitter<ManageTeamsState> emit,
  ) async {
    if (state.teamId == null ||
        state.gameId == null ||
        state.teamName == null ||
        state.teamSize == null) {
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

    await execute(
      action: () async {
        await _teamsRepository.addMember(
          teamId: state.teamId!,
          userId: event.userId,
        );

        final teamMembers = await _teamsRepository.getTeamMembers(
          state.teamId!,
        );
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
      },
      onError: (message) => emit(ManageTeamsError(message)),
      context: 'manage_teams',
      errorMessages: BlocErrorHandlerMixin.teamErrors,
      defaultMessage: 'Failed to add member',
    );
  }

  Future<void> _onRemoveMember(
    ManageTeamsRemoveMember event,
    Emitter<ManageTeamsState> emit,
  ) async {
    if (state.teamId == null ||
        state.gameId == null ||
        state.teamName == null ||
        state.teamSize == null) {
      return;
    }

    await execute(
      action: () async {
        await _teamsRepository.removeMember(
          teamId: state.teamId!,
          userId: event.userId,
        );

        final teamMembers = await _teamsRepository.getTeamMembers(
          state.teamId!,
        );
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
      },
      onError: (message) => emit(ManageTeamsError(message)),
      context: 'manage_teams',
      defaultMessage: 'Failed to remove member',
    );
  }
}
