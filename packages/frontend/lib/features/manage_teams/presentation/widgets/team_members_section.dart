import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/manage_teams/logic/manage_teams_bloc.dart';
import 'package:frontend/features/manage_teams/logic/manage_teams_event.dart';
import 'package:shared_models/shared_models.dart';

class TeamMembersSection extends StatelessWidget {
  const TeamMembersSection({
    required this.teamName,
    required this.teamMembers,
    required this.currentUserId,
    this.teamSize,
    super.key,
  });

  final String teamName;
  final List<AppUser> teamMembers;
  final String currentUserId;
  final int? teamSize;

  @override
  Widget build(BuildContext context) {
    AppUser? captain;
    try {
      captain = teamMembers.firstWhere((u) => u.role == UserRole.captain);
    } catch (e) {
      captain = teamMembers.isNotEmpty ? teamMembers.first : null;
    }
    final isCaptain = captain?.id == currentUserId;

    return SectionCard(
      icon: Icons.people_rounded,
      title: teamSize != null
          ? '$teamName (${teamMembers.length}/$teamSize)'
          : '$teamName (${teamMembers.length})',
      child: teamMembers.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No team members yet'),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: teamMembers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final member = teamMembers[index];
                final isMemberCaptain =
                    captain != null && member.id == captain.id;
                final canRemove = isCaptain && !isMemberCaptain;

                return ListTile(
                  leading: member.avatarUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(member.avatarUrl!),
                        )
                      : CircleAvatar(
                          child: Text(
                            member.globalName?.substring(0, 1).toUpperCase() ??
                                member.username
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'U',
                          ),
                        ),
                  title: Text(
                    member.globalName ?? member.username ?? 'Unknown',
                  ),
                  subtitle: isMemberCaptain
                      ? const Text(
                          'Captain',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                  trailing: canRemove
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: Theme.of(context).colorScheme.error,
                          onPressed: () {
                            context.read<ManageTeamsBloc>().add(
                              ManageTeamsRemoveMember(member.id),
                            );
                          },
                        )
                      : null,
                );
              },
            ),
    );
  }
}
