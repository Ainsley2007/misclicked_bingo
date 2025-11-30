import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:frontend/core/widgets/widgets.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_bloc.dart';
import 'package:frontend/features/manage_team/logic/manage_teams_event.dart';
import 'package:shared_models/shared_models.dart';

class TeamMembersSection extends StatelessWidget {
  const TeamMembersSection({
    required this.teamName,
    required this.teamMembers,
    required this.currentUserId,
    required this.teamColor,
    this.teamSize,
    super.key,
  });

  final String teamName;
  final List<AppUser> teamMembers;
  final String currentUserId;
  final String teamColor;
  final int? teamSize;

  Color _parseColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    AppUser? captain;
    try {
      captain = teamMembers.firstWhere((u) => u.role == UserRole.captain);
    } catch (e) {
      captain = teamMembers.isNotEmpty ? teamMembers.first : null;
    }
    final isCaptain = captain?.id == currentUserId;
    final color = _parseColor(teamColor);

    return SectionCard(
      icon: Icons.people_rounded,
      title: teamSize != null
          ? '$teamName (${teamMembers.length}/$teamSize)'
          : '$teamName (${teamMembers.length})',
      trailing: _TeamColorPicker(
        color: color,
        isCaptain: isCaptain,
        onColorChanged: (newColor) {
          final hexColor =
              '#${newColor.value.toRadixString(16).substring(2).toUpperCase()}';
          context.read<ManageTeamsBloc>().add(ManageTeamsUpdateColor(hexColor));
        },
      ),
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

class _TeamColorPicker extends StatelessWidget {
  const _TeamColorPicker({
    required this.color,
    required this.isCaptain,
    required this.onColorChanged,
  });

  final Color color;
  final bool isCaptain;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Team Color',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: isCaptain ? () => _showColorPicker(context) : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: isCaptain
                ? Icon(
                    Icons.edit,
                    size: 14,
                    color: color.computeLuminance() > 0.5
                        ? Colors.black54
                        : Colors.white70,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    var pickedColor = color;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pick Team Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickedColor,
            onColorChanged: (c) => pickedColor = c,
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onColorChanged(pickedColor);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
