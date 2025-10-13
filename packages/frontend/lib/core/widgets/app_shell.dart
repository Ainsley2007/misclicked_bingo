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
    return Scaffold(appBar: _buildAppBar(context), body: child);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final accent = AppColors.of(context).accent;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      title: Row(
        children: [
          Icon(Icons.grid_3x3_rounded, color: accent, size: 28),
          const SizedBox(width: 12),
          Text('Misclicked Bingo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(width: 48),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final user = state.user;
              if (user == null) return const SizedBox.shrink();

              return Row(
                children: [
                  _NavButton(label: 'Lobby', icon: Icons.home_rounded, path: '/lobby', isSelected: currentLocation == '/lobby'),
                  const SizedBox(width: 8),
                  _NavButton(label: 'Profile', icon: Icons.person_rounded, path: '/profile', isSelected: currentLocation == '/profile'),
                  if (user.role == UserRole.admin) ...[
                    const SizedBox(width: 8),
                    _NavButton(label: 'Admin', icon: Icons.admin_panel_settings_rounded, path: '/admin', isSelected: currentLocation == '/admin'),
                  ],
                ],
              );
            },
          ),
        ],
      ),
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state.user;
            if (user == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [accent, accent.withValues(alpha: 0.7)]),
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.transparent,
                          child: Text(
                            user.globalName?.substring(0, 1).toUpperCase() ?? user.username?.substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.globalName ?? user.username ?? 'Unknown', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          Text(
                            user.role.name.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: accent, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.icon, required this.path, required this.isSelected});

  final String label;
  final IconData icon;
  final String path;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).accent;

    return TextButton.icon(
      onPressed: () => context.go(path),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? accent : null,
        backgroundColor: isSelected ? accent.withValues(alpha: 0.12) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
