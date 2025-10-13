import 'package:flutter/material.dart';
import 'package:frontend/features/auth/logic/auth_bloc.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:web/web.dart' as web;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).extension<AppColors>()!.accent;

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
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: Icon(Icons.grid_3x3_rounded, size: 64, color: accent),
                    ),
                    const SizedBox(height: 32),
                    Text('Misclicked Bingo', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    const SizedBox(height: 12),
                    Text(
                      'Sign in with Discord to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _loginWithDiscord(context),
                        icon: const Icon(Icons.discord, size: 24),
                        label: const Text('Continue with Discord'),
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
    final loginUrl = sl<AuthBloc>().getLoginUrl();
    web.window.location.href = loginUrl;
  }
}
