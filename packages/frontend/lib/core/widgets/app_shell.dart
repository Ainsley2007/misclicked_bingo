import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/logic/auth_bloc.dart';
import 'package:shared_models/shared_models.dart';
import 'package:frontend/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _NavigationSidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavigationSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final accent = AppColors.of(context).accent;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.grid_3x3_rounded, color: accent, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Misclicked Bingo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final user = state.user;
                if (user == null) return const SizedBox.shrink();

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _NavItem(icon: Icons.home_rounded, label: 'Lobby', path: '/lobby', isSelected: currentLocation == '/lobby'),
                    _NavItem(icon: Icons.person_rounded, label: 'Profile', path: '/profile', isSelected: currentLocation == '/profile'),
                    if (user.role == UserRole.admin) ...[
                      const Divider(height: 16),
                      _NavItem(icon: Icons.admin_panel_settings_rounded, label: 'Admin', path: '/admin', isSelected: currentLocation == '/admin'),
                    ],
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          _UserSection(),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.path, required this.isSelected});

  final IconData icon;
  final String label;
  final String path;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).accent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? accent : null),
        title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
        selected: isSelected,
        selectedTileColor: accent.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => context.go(path),
      ),
    );
  }
}

class _UserSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).accent;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        if (user == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accent, accent.withValues(alpha: 0.7)]),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    user.globalName?.substring(0, 1).toUpperCase() ?? user.username?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.globalName ?? user.username ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(user.role.name, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: accent)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
