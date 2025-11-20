import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.icon,
    this.title,
    required this.child,
    super.key,
  });

  final IconData icon;
  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              _SectionHeader(icon: icon, title: title!),
              const SizedBox(height: 24),
            ] else ...[
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(height: 20),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
        ),
      ],
    );
  }
}
