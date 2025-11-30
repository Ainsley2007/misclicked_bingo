import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:web/web.dart' as web;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).accent;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accent.withValues(alpha: 0.2)),
                      ),
                      child: Icon(Icons.grid_3x3_rounded, size: 48, color: accent),
                    ),
                    const SizedBox(height: 24),
                    Text('Misclicked Bingo', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in with Discord to continue',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _loginWithDiscord(context),
                        icon: const Icon(Icons.discord, size: 20),
                        label: const Text('Continue with Discord'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/guest'),
                        icon: const Icon(Icons.visibility_outlined, size: 20),
                        label: const Text('View Games as Guest'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _loginWithDiscord(BuildContext context) {
    final loginUrl = sl<AuthService>().getLoginUrl();
    web.window.location.href = loginUrl;
  }
}
