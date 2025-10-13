import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/auth/logic/auth_bloc.dart';
import 'package:shared_models/shared_models.dart';
import 'package:frontend/core/widgets/widgets.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return _JoinGameView(user: user);
      },
    );
  }
}

class _JoinGameView extends StatelessWidget {
  const _JoinGameView({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SectionCard(
            icon: Icons.sports_esports_rounded,
            child: Column(
              children: [
                const TextField(
                  decoration: InputDecoration(labelText: 'Game Code', prefixIcon: Icon(Icons.tag_rounded)),
                  maxLength: 6,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(labelText: 'Team Name', prefixIcon: Icon(Icons.people_rounded)),
                ),
                const SizedBox(height: 24),
                FullWidthButton(
                  onPressed: () {
                    // TODO: Implement join game
                  },
                  icon: Icons.login_rounded,
                  label: 'Join Game',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
