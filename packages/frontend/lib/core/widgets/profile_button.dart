import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';
import 'package:frontend/theme/app_theme.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({required this.user, super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).accent;

    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 56),
      splashRadius: 0.1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAvatar(accent),
            const SizedBox(width: 12),
            _buildUserInfo(context, accent),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(
                Icons.person_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              const Text('Profile'),
            ],
          ),
        ),
        if (user.role == UserRole.admin)
          PopupMenuItem<String>(
            value: 'admin',
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                const Text('Admin Panel'),
              ],
            ),
          ),
      ],
      onSelected: (value) {
        if (value == 'profile') {
          context.go('/profile');
        } else if (value == 'admin') {
          context.go('/admin');
        }
      },
    );
  }

  Widget _buildAvatar(Color accent) {
    if (user.avatarUrl != null) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(user.avatarUrl!),
        backgroundColor: accent,
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Failed to load avatar: $exception');
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [accent, accent.withValues(alpha: 0.7)],
        ),
      ),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.transparent,
        child: Text(
          user.globalName?.substring(0, 1).toUpperCase() ??
              user.username?.substring(0, 1).toUpperCase() ??
              'U',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, Color accent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.globalName ?? user.username ?? 'Unknown',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          user.role.name.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: accent,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
