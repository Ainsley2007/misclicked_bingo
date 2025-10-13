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
    final accent = AppColors.of(context).accent;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      toolbarHeight: 72,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: InkWell(
          onTap: () => context.go('/lobby'),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.grid_3x3_rounded, color: accent, size: 28),
                const SizedBox(width: 12),
                Text('OSRS Bingo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              ],
            ),
          ),
        ),
      ),
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state.user;
            if (user == null) return const SizedBox.shrink();
            
            print('User avatar field: ${user.avatar}');
            print('User avatarUrl: ${user.avatarUrl}');

            return Padding(
              padding: const EdgeInsets.only(right: 24, top: 12, bottom: 12),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                          user.avatarUrl != null
                              ? CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(user.avatarUrl!),
                                  backgroundColor: accent,
                                  onBackgroundImageError: (exception, stackTrace) {
                                    print('Failed to load avatar: $exception');
                                  },
                                )
                              : Container(
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
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                        ],
                      ),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface),
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
                          Icon(Icons.admin_panel_settings_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface),
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
              ),
            );
          },
        ),
      ],
    );
  }
}
