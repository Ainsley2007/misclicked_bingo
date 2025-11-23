import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

class BingoTileCard extends StatelessWidget {
  const BingoTileCard({
    required this.tile,
    required this.isCompleted,
    required this.onTap,
    super.key,
  });

  final BingoTile tile;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/image/tile.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              if (isCompleted) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
                  ),
                ),
              ],
              _BingoTileContent(tile: tile),
            ],
          ),
        ],
      ),
    );
  }
}

class _BingoTileContent extends StatelessWidget {
  const _BingoTileContent({required this.tile});

  final BingoTile tile;

  @override
  Widget build(BuildContext context) {
    final bossTypeColor = _getBossTypeColor(tile.bossType);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (tile.bossIconUrl != null) ...[
            const SizedBox(height: 16),
            Image.network(
              tile.bossIconUrl!,
              fit: BoxFit.contain,
              width: 48,
              height: 48,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 12),
          ],
          Container(
            height: 1.5,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            color: bossTypeColor,
          ),
          const SizedBox(height: 12),
          _buildUniqueItemsSection(context),
        ],
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
      return Center(
        child: Text(
          'Any unique',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (tile.uniqueItems.isEmpty) {
      return const SizedBox.shrink();
    }

    if (tile.uniqueItems.length == 1) {
      final item = tile.uniqueItems.first;
      final text = item.requiredCount > 1
          ? '${item.requiredCount}x ${item.itemName}'
          : item.itemName;
      return Center(
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    final items = tile.uniqueItems.map((item) {
      return item.requiredCount > 1
          ? '${item.requiredCount}x ${item.itemName}'
          : item.itemName;
    }).toList();

    if (tile.isOrLogic) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                tile.anyNCount != null && tile.anyNCount! > 1
                    ? 'Any ${tile.anyNCount} of:'
                    : 'Any of:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            ...items.map(
              (itemText) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(
                  itemText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'All of:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...items.map(
            (itemText) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Text(
                itemText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
                    
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.85),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        child: _buildUniqueItemsSection(context),
                      ),
                    ),
*/
