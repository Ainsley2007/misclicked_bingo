import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/logic/auth_bloc.dart';
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

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final user = state.user;
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
    if (path.startsWith('/game/')) {
      return const _PageInfo(title: 'Game', icon: Icons.sports_esports_rounded);
    }

    switch (path) {
      case '/lobby':
        return const _PageInfo(title: 'Lobby', icon: Icons.home_rounded);
      case '/manage-teams':
        return const _PageInfo(
          title: 'Manage Teams',
          icon: Icons.groups_rounded,
        );
      case '/profile':
        return const _PageInfo(title: 'Profile', icon: Icons.person_rounded);
      case '/admin':
        return const _PageInfo(
          title: 'Admin Panel',
          icon: Icons.admin_panel_settings_rounded,
        );
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
