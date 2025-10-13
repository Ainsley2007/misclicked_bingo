import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/logic/auth_bloc.dart';
import 'package:frontend/core/widgets/profile_button.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
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
}
