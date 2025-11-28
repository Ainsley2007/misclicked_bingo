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
      offset: const Offset(0, 54),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            _buildAvatar(accent),
            _buildUserInfo(context, accent),
            Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'profile',
          height: 40,
          child: Row(
            children: [
              Icon(Icons.person_rounded, size: 18, color: Theme.of(context).colorScheme.onSurface),
              const SizedBox(width: 12),
              Text('Profile', style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
        if (user.role == UserRole.admin)
          PopupMenuItem<String>(
            value: 'admin',
            height: 40,
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings_rounded, size: 18, color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(width: 12),
                Text('Admin Panel', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
      ],
      onSelected: (value) {
        final currentLocation = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;

        if ((value == 'profile' && currentLocation == '/profile') || (value == 'admin' && currentLocation.startsWith('/admin'))) {
          return;
        }

        if (value == 'profile') {
          Router.neglect(context, () => context.go('/profile'));
        } else if (value == 'admin') {
          Router.neglect(context, () => context.go('/admin'));
        }
      },
    );
  }

  Widget _buildAvatar(Color accent) {
    if (user.avatarUrl != null) {
      return CircleAvatar(
        radius: 14,
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
        gradient: LinearGradient(colors: [accent, accent.withValues(alpha: 0.7)]),
      ),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: Colors.transparent,
        child: Text(
          user.globalName?.substring(0, 1).toUpperCase() ?? user.username?.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, Color accent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(user.globalName ?? user.username ?? 'Unknown', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
        Text(
          user.role.name.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: accent, fontWeight: FontWeight.w700, letterSpacing: 0.8, fontSize: 10),
        ),
      ],
    );
  }
}
