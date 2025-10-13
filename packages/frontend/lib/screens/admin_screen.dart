import 'package:flutter/material.dart';
import 'package:frontend/widgets/widgets.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionCard(
                icon: Icons.add_circle_rounded,
                title: 'Create New Game',
                child: Column(
                  children: [
                    const TextField(
                      decoration: InputDecoration(labelText: 'Game Name', hintText: 'Enter game name', prefixIcon: Icon(Icons.sports_esports_rounded)),
                    ),
                    const SizedBox(height: 24),
                    FullWidthButton(
                      onPressed: () {
                        // TODO: Implement create game
                      },
                      icon: Icons.add_rounded,
                      label: 'Create Game',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionCard(
                icon: Icons.list_rounded,
                title: 'Manage Games',
                child: Center(
                  child: Text('No games yet', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
