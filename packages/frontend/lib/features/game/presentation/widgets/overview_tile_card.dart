import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';

// Original tile image is 296x296 with 10px border
// Border ratio: 10/296 ≈ 0.0338 (3.38%)
const double _tileBorderRatio = 10 / 296;

class OverviewTileCard extends StatelessWidget {
  const OverviewTileCard({
    required this.tile,
    required this.isCompleted,
    this.hasProofs = false,
    super.key,
  });

  final BingoTile tile;
  final bool isCompleted;
  final bool hasProofs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = constraints.maxWidth;
        // Calculate border padding based on tile size
        final borderPadding = tileSize * _tileBorderRatio;

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
                padding: EdgeInsets.all(borderPadding),
                child: Container(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.20),
                ),
              ),
            // Proof indicator (amber border for tiles with proofs but not completed)
            if (hasProofs && !isCompleted)
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(borderPadding * 0.5),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFFFA000),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            _OverviewTileContent(tile: tile),
            // Small camera icon for tiles with proofs
            if (hasProofs && !isCompleted)
              Positioned(
                bottom: borderPadding * 0.5,
                left: borderPadding * 0.5,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA000),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OverviewTileContent extends StatelessWidget {
  const _OverviewTileContent({required this.tile});

  final BingoTile tile;

  @override
  Widget build(BuildContext context) {
    final bossTypeColor = _getBossTypeColor(tile.bossType);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = constraints.maxWidth;
        // Scale icon relative to tile size
        final iconSize = (tileSize * 0.40).clamp(16.0, 44.0);
        final lineMargin = tileSize * 0.20;
        final spacing = tileSize * 0.04;
        final padding = tileSize * 0.08;

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tile.bossIconUrl != null) ...[
                Image.network(
                  tile.bossIconUrl!,
                  fit: BoxFit.contain,
                  width: iconSize,
                  height: iconSize,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
                SizedBox(height: spacing),
              ],
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: lineMargin),
                color: bossTypeColor,
              ),
            ],
          ),
        ),
        );
      },
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
