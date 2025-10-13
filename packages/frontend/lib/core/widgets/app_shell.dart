import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/auth/logic/auth_bloc.dart';
import 'package:frontend/core/widgets/profile_button.dart';
import 'package:frontend/theme/app_theme.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: child,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final accent = AppColors.of(context).accent;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      toolbarHeight: 72,
      actions: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state.user;
            if (user == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(right: 24, top: 12, bottom: 12),
              child: ProfileButton(user: user),
            );
          },
        ),
      ],
    );
  }
}
