import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_bloc.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_event.dart';
import 'package:shared_models/shared_models.dart';

class AvailableUsersSection extends StatelessWidget {
  const AvailableUsersSection({
    required this.availableUsers,
    required this.unavailableUsers,
    this.onRefresh,
    this.isLoading = false,
    super.key,
  });

  final List<AppUser> availableUsers;
  final List<AppUser> unavailableUsers;
  final VoidCallback? onRefresh;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.person_add_rounded,
      title: 'All Users',
      trailing: IconButton(
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.refresh_rounded, size: 20),
        tooltip: 'Refresh users',
        onPressed: isLoading ? null : onRefresh,
      ),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (availableUsers.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Available (${availableUsers.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: availableUsers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = availableUsers[index];
                      return _buildUserTile(context, user, isAvailable: true);
                    },
                  ),
                ],
                if (unavailableUsers.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'In Other Teams (${unavailableUsers.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: unavailableUsers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = unavailableUsers[index];
                      return _buildUserTile(context, user, isAvailable: false);
                    },
                  ),
                ],
                if (availableUsers.isEmpty && unavailableUsers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No other users in this game'),
                  ),
              ],
            ),
    );
  }

  Widget _buildUserTile(
    BuildContext context,
    AppUser user, {
    required bool isAvailable,
  }) {
    return ListTile(
      leading: user.avatarUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl!))
          : CircleAvatar(
              child: Text(
                user.globalName?.substring(0, 1).toUpperCase() ??
                    user.username?.substring(0, 1).toUpperCase() ??
                    'U',
              ),
            ),
      title: Text(user.globalName ?? user.username ?? 'Unknown'),
      subtitle: Text(isAvailable ? 'No team' : 'In another team'),
      trailing: isAvailable
          ? IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                context.read<ManageTeamsBloc>().add(
                  ManageTeamsAddMember(user.id),
                );
              },
            )
          : null,
    );
  }
}
