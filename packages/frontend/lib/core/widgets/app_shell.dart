import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/core/widgets/profile_button.dart';
import 'package:shared_models/shared_models.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.2);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: StreamBuilder<AuthState>(
              stream: sl<AuthService>().authStream,
              initialData: sl<AuthService>().currentState,
              builder: (context, snapshot) {
                final user = snapshot.data?.user;
                if (user == null) return const SizedBox.shrink();

                return Row(
                  children: [
                    _buildBrandSection(context),
                    const SizedBox(width: 32),
                    Expanded(child: _buildNavItems(context, user)),
                    const SizedBox(width: 16),
                    ProfileButton(user: user),
                  ],
                );
              },
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.grid_on_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 20),
        ),
        const SizedBox(width: 12),
        Text('Misclicked Bingo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3)),
      ],
    );
  }

  Widget _buildNavItems(BuildContext context, AppUser user) {
    final currentPath = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;

    final navItems = <_NavItem>[
      _NavItem(label: 'Lobby', icon: Icons.home_rounded, path: '/lobby', isActive: currentPath == '/lobby', isVisible: user.gameId == null),
      _NavItem(
        label: 'Game',
        icon: Icons.sports_esports_rounded,
        path: user.gameId != null ? '/game/${user.gameId}' : null,
        isActive: currentPath.startsWith('/game/') && !currentPath.endsWith('/overview'),
        isVisible: user.gameId != null,
      ),
      _NavItem(
        label: 'Overview',
        icon: Icons.dashboard_rounded,
        path: user.gameId != null ? '/game/${user.gameId}/overview' : null,
        isActive: currentPath.endsWith('/overview'),
        isVisible: user.gameId != null,
      ),
      _NavItem(
        label: 'Manage Team',
        icon: Icons.groups_rounded,
        path: '/manage-team',
        isActive: currentPath == '/manage-team',
        isVisible: user.gameId != null && user.teamId != null,
      ),
    ];

    final visibleItems = navItems.where((item) => item.isVisible).toList();

    return Row(
      children: visibleItems
          .map(
            (item) => _NavItemWidget(
              item: item,
              onTap: item.path != null
                  ? () {
                      if (!item.isActive) {
                        Router.neglect(context, () => context.go(item.path!));
                      }
                    }
                  : null,
            ),
          )
          .toList(),
    );
  }
}

class _NavItem {
  const _NavItem({required this.label, required this.icon, required this.path, required this.isActive, required this.isVisible});

  final String label;
  final IconData icon;
  final String? path;
  final bool isActive;
  final bool isVisible;
}

class _NavItemWidget extends StatelessWidget {
  const _NavItemWidget({required this.item, required this.onTap});

  final _NavItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = item.isActive;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? colorScheme.primaryContainer.withValues(alpha: 0.4) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isActive ? Border.all(color: colorScheme.primary.withValues(alpha: 0.3)) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 18, color: isActive ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
