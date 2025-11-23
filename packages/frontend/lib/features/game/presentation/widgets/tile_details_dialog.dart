import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

class TileDetailsDialog extends StatelessWidget {
  const TileDetailsDialog({
    required this.tile,
    required this.isCompleted,
    required this.bosses,
    super.key,
  });

  final BingoTile tile;
  final bool isCompleted;
  final List<Boss> bosses;

  List<String>? get _bossUniqueItems {
    if (!tile.isAnyUnique) return null;
    try {
      final boss = bosses.firstWhere((b) => b.id == tile.bossId);
      return boss.uniqueItems;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bossTypeColor = _getBossTypeColor(tile.bossType);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    if (tile.bossIconUrl != null) ...[
                      Image.network(
                        tile.bossIconUrl!,
                        fit: BoxFit.contain,
                        width: 96,
                        height: 96,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      color: bossTypeColor,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      tile.description ?? tile.bossName ?? 'Unknown Boss',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    if (tile.bossName != null && tile.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        tile.bossName!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 32),
                    _buildUniqueItemsSection(context),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton.icon(
                    onPressed: null,
                    icon: Icon(
                      isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.check_circle_outline,
                    ),
                    label: Text(isCompleted ? 'Completed' : 'Mark Complete'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBossTypeColor(BossType? type) {
    return switch (type) {
      BossType.easy => const Color(0xFF4CAF50), // Green
      BossType.solo => const Color(0xFF9C27B0), // Purple
      BossType.group => const Color(0xFFE11D48), // Red
      BossType.slayer => const Color(0xFFFF9800), // Orange
      null => const Color(0xFF4CAF50), // Default to green
    };
  }

  Widget _buildUniqueItemsSection(BuildContext context) {
    if (tile.isAnyUnique) {
      final uniqueItems = _bossUniqueItems;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Any unique',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Any unique item from ${tile.bossName ?? "this boss"}\'s drop table:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (uniqueItems == null || uniqueItems.isEmpty)
              Text(
                'No unique items available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...uniqueItems.map(
                (itemName) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          itemName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (tile.uniqueItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tile.isOrLogic
                ? (tile.anyNCount != null && tile.anyNCount! > 1
                      ? 'Any ${tile.anyNCount} of:'
                      : 'Any of:')
                : 'All of:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...tile.uniqueItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.itemName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  if (item.requiredCount > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'x${item.requiredCount}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
