import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/features/auth/logic/auth_bloc.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_bloc.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_event.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_state.dart';
import 'package:frontend/features/manage_team/presentation/widgets/available_users_section.dart';
import 'package:frontend/features/manage_team/presentation/widgets/team_members_section.dart';

class ManageTeamScreen extends StatelessWidget {
  const ManageTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState.user;
        if (user == null || user.teamId == null || user.gameId == null) {
          return const Center(child: Text('You are not part of a team'));
        }

        return BlocProvider(
          create: (_) => sl<ManageTeamsBloc>()
            ..add(
              ManageTeamsLoadRequested(
                teamId: user.teamId!,
                gameId: user.gameId!,
              ),
            ),
          child: _ManageTeamsView(teamId: user.teamId!, currentUserId: user.id),
        );
      },
    );
  }
}

class _ManageTeamsView extends StatelessWidget {
  const _ManageTeamsView({required this.teamId, required this.currentUserId});

  final String teamId;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManageTeamsBloc, ManageTeamsState>(
      builder: (context, state) {
        if (state.status == ManageTeamsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ManageTeamsStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.errorMessage}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    context.read<ManageTeamsBloc>().add(
                      ManageTeamsLoadRequested(
                        teamId: teamId,
                        gameId: state.gameId ?? '',
                      ),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TeamMembersSection(
                            teamName: state.teamName ?? 'Your Team',
                            teamMembers: state.teamMembers,
                            currentUserId: currentUserId,
                            teamSize: state.teamSize,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: AvailableUsersSection(
                            availableUsers: state.availableUsers,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        TeamMembersSection(
                          teamName: state.teamName ?? 'Your Team',
                          teamMembers: state.teamMembers,
                          currentUserId: currentUserId,
                          teamSize: state.teamSize,
                        ),
                        const SizedBox(height: 24),
                        AvailableUsersSection(
                          availableUsers: state.availableUsers,
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
