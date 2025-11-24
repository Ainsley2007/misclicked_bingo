import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_bloc.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_event.dart';
import 'package:shared_models/shared_models.dart';

class AvailableUsersSection extends StatelessWidget {
  const AvailableUsersSection({required this.availableUsers, super.key});

  final List<AppUser> availableUsers;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.person_add_rounded,
      title: 'Available Users (${availableUsers.length})',
      child: availableUsers.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No available users to add'),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: availableUsers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = availableUsers[index];
                return ListTile(
                  leading: user.avatarUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(user.avatarUrl!),
                        )
                      : CircleAvatar(
                          child: Text(
                            user.globalName?.substring(0, 1).toUpperCase() ??
                                user.username?.substring(0, 1).toUpperCase() ??
                                'U',
                          ),
                        ),
                  title: Text(user.globalName ?? user.username ?? 'Unknown'),
                  subtitle: const Text('No team'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () {
                      context.read<ManageTeamsBloc>().add(
                        ManageTeamsAddMember(user.id),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
