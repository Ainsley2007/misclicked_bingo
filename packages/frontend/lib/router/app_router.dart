import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/features/admin/presentation/admin_screen.dart';
import 'package:frontend/features/lobby/presentation/lobby_screen.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/presentation/profile_screen.dart';
import 'package:frontend/features/game/presentation/game_screen.dart';
import 'package:frontend/features/manage_team/presentation/manage_team_screen.dart';
import 'package:frontend/features/game_creation/presentation/game_creation_screen.dart';
import 'package:frontend/core/widgets/app_shell.dart';

class AppRouter {
  static GoRouter router(AuthService authService) {
    return GoRouter(
      initialLocation: '/lobby',
      refreshListenable: _GoRouterRefreshStream(authService.authStream),
      redirect: (context, state) {
        final status = authService.currentState.status;
        final user = authService.currentState.user;
        final isLoginRoute = state.matchedLocation == '/login';

        if (status == AuthStatus.unknown) {
          return null;
        }

        if (status == AuthStatus.unauthenticated && !isLoginRoute) {
          return '/login';
        }

        if (status == AuthStatus.authenticated && isLoginRoute) {
          // Redirect to game if user is in a game, otherwise lobby
          if (user?.gameId != null) {
            return '/game/${user!.gameId}';
          }
          return '/lobby';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => _noTransitionPage(state: state, child: const LoginScreen()),
        ),
        ShellRoute(
          pageBuilder: (context, state, child) => _noTransitionPage(
            state: state,
            child: AppShell(child: child),
          ),
          routes: [
            GoRoute(
              path: '/lobby',
              pageBuilder: (context, state) => _noTransitionPage(state: state, child: const LobbyScreen()),
            ),
            GoRoute(
              path: '/game/:gameId',
              pageBuilder: (context, state) {
                final gameId = state.pathParameters['gameId']!;
                return _noTransitionPage(
                  state: state,
                  child: GameScreen(gameId: gameId),
                );
              },
            ),
            GoRoute(
              path: '/manage-team',
              pageBuilder: (context, state) => _noTransitionPage(state: state, child: const ManageTeamScreen()),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => _noTransitionPage(state: state, child: const ProfileScreen()),
            ),
            GoRoute(path: '/admin', redirect: (context, state) => '/admin/games'),
            GoRoute(
              path: '/admin/games',
              pageBuilder: (context, state) => _noTransitionPage(state: state, child: const AdminScreen()),
            ),
            GoRoute(
              path: '/admin/games/create',
              pageBuilder: (context, state) => _noTransitionPage(state: state, child: const GameCreationScreen()),
            ),
          ],
        ),
      ],
    );
  }

  static CustomTransitionPage<void> _noTransitionPage({required GoRouterState state, required Widget child}) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
      transitionDuration: Duration.zero,
    );
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
