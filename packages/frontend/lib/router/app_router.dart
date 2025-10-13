import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/logic/auth_bloc.dart';
import 'package:frontend/features/admin/presentation/admin_screen.dart';
import 'package:frontend/features/lobby/presentation/lobby_screen.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/presentation/profile_screen.dart';
import 'package:frontend/core/widgets/app_shell.dart';

class AppRouter {
  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/lobby',
      refreshListenable: _GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final status = authBloc.state.status;
        final isLoginRoute = state.matchedLocation == '/login';

        if (status == AuthStatus.unknown) {
          return null;
        }

        if (status == AuthStatus.unauthenticated && !isLoginRoute) {
          return '/login';
        }

        if (status == AuthStatus.authenticated && isLoginRoute) {
          return '/lobby';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) =>
              _noTransitionPage(state: state, child: const LoginScreen()),
        ),
        ShellRoute(
          pageBuilder: (context, state, child) => _noTransitionPage(
            state: state,
            child: AppShell(child: child),
          ),
          routes: [
            GoRoute(
              path: '/lobby',
              pageBuilder: (context, state) =>
                  _noTransitionPage(state: state, child: const LobbyScreen()),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) =>
                  _noTransitionPage(state: state, child: const ProfileScreen()),
            ),
            GoRoute(
              path: '/admin',
              pageBuilder: (context, state) =>
                  _noTransitionPage(state: state, child: const AdminScreen()),
            ),
          ],
        ),
      ],
    );
  }

  static CustomTransitionPage<void> _noTransitionPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
      transitionDuration: Duration.zero,
    );
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
