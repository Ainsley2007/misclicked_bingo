import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/core/widgets/profile_button.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    final pageInfo = _getPageInfo(currentPath);

    final borderColor = Theme.of(
      context,
    ).colorScheme.primary.withValues(alpha: 0.2);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Icon(
                    pageInfo.icon,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  pageInfo.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                StreamBuilder<AuthState>(
                  stream: sl<AuthService>().authStream,
                  initialData: sl<AuthService>().currentState,
                  builder: (context, snapshot) {
                    final user = snapshot.data?.user;
                    if (user == null) return const SizedBox.shrink();
                    return ProfileButton(user: user);
                  },
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  _PageInfo _getPageInfo(String path) {
    if (path.endsWith('/overview')) {
      return const _PageInfo(title: 'Overview', icon: Icons.dashboard_rounded);
    }
    if (path.startsWith('/game/')) {
      return const _PageInfo(title: 'Game', icon: Icons.sports_esports_rounded);
    }

    if (path.startsWith('/admin/games/create')) {
      return const _PageInfo(
        title: 'Create Game',
        icon: Icons.add_circle_rounded,
      );
    }

    if (path.startsWith('/admin/games') || path.startsWith('/admin')) {
      return const _PageInfo(
        title: 'Admin Panel',
        icon: Icons.admin_panel_settings_rounded,
      );
    }

    switch (path) {
      case '/lobby':
        return const _PageInfo(title: 'Lobby', icon: Icons.home_rounded);
      case '/manage-team':
        return const _PageInfo(
          title: 'Manage Team',
          icon: Icons.groups_rounded,
        );
      case '/profile':
        return const _PageInfo(title: 'Profile', icon: Icons.person_rounded);
      default:
        return const _PageInfo(title: 'Lobby', icon: Icons.home_rounded);
    }
  }
}

class _PageInfo {
  const _PageInfo({required this.title, required this.icon});
  final String title;
  final IconData icon;
}
