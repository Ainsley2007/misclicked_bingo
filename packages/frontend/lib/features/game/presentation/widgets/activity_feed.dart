import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/shared_models.dart';

class ActivityFeed extends StatelessWidget {
  final List<TileActivity> activities;
  final bool isLoading;

  const ActivityFeed({
    required this.activities,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No activity yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload proofs and complete tiles\nto see activity here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ActivityCard(activity: activity),
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final TileActivity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompletion = activity.type == ActivityType.tileCompleted;
    final accentColor = isCompletion ? const Color(0xFF4CAF50) : colorScheme.primary;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.2),
                    accentColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCompletion ? Icons.check_circle : Icons.upload_file,
                size: 22,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text: activity.username ?? 'Someone',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: isCompletion ? ' completed ' : ' uploaded proof for ',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        TextSpan(
                          text: activity.tileName ?? 'a tile',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (activity.teamName != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.group,
                                size: 12,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                activity.teamName!,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatRelativeTime(activity.timestamp),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (activity.tileIconUrl != null)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  activity.tileIconUrl!,
                  width: 32,
                  height: 32,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }
}

