import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

class OverviewTileCard extends StatelessWidget {
  const OverviewTileCard({
    required this.tile,
    required this.isCompleted,
    super.key,
  });

  final BingoTile tile;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/image/tile.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        if (isCompleted)
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.20),
            ),
          ),
        _OverviewTileContent(tile: tile),
      ],
    );
  }
}

class _OverviewTileContent extends StatelessWidget {
  const _OverviewTileContent({required this.tile});

  final BingoTile tile;

  @override
  Widget build(BuildContext context) {
    final bossTypeColor = _getBossTypeColor(tile.bossType);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tile.bossIconUrl != null) ...[
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
            margin: const EdgeInsets.symmetric(horizontal: 32),
            color: bossTypeColor,
          ),
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
}
