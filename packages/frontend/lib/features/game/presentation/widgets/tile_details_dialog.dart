import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

class TileDetailsDialog extends StatelessWidget {
  const TileDetailsDialog({required this.tile, required this.onToggleCompletion, super.key});

  final BingoTile tile;
  final VoidCallback onToggleCompletion;

  @override
  Widget build(BuildContext context) {
    final bossTypeColor = _getBossTypeColor(tile.bossType);

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
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
                      Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 60), color: bossTypeColor),
                      const SizedBox(height: 24),
                      Text(
                        tile.description ?? tile.bossName ?? 'Unknown Boss',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      if (tile.bossName != null && tile.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          tile.bossName!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 32),
                      _buildUniqueItemsSection(context),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 12,
                children: [
                  _buildButton(context: context, label: 'Close', onPressed: () => Navigator.of(context).pop(), isPrimary: false),
                  if (tile.isCompleted)
                    _buildButton(
                      context: context,
                      label: 'Undo Completion',
                      onPressed: () {
                        onToggleCompletion();
                        Navigator.of(context).pop();
                      },
                      isPrimary: false,
                    ),
                  if (!tile.isCompleted)
                    _buildButton(
                      context: context,
                      label: 'Mark Complete',
                      onPressed: () {
                        onToggleCompletion();
                        Navigator.of(context).pop();
                      },
                      isPrimary: true,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required BuildContext context, required String label, required VoidCallback onPressed, required bool isPrimary}) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      );
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.onSurface.withValues(alpha: 0.7),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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
      final uniqueItems = tile.possibleUniqueItems;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Any unique', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
            Text(
              'Any unique item from ${tile.bossName ?? "this boss"}\'s drop table:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            if (uniqueItems == null || uniqueItems.isEmpty)
              Text('No unique items available', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))
            else
              ...uniqueItems.map(
                (itemName) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(itemName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5))),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tile.isOrLogic ? (tile.anyNCount != null && tile.anyNCount! > 1 ? 'Any ${tile.anyNCount} of:' : 'Any of:') : 'All of:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 16),
          ...tile.uniqueItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item.itemName, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5))),
                  if (item.requiredCount > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'x${item.requiredCount}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 11),
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
