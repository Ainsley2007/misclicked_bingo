import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:shared_models/shared_models.dart';

const double _tileBorderRatio = 11.5 / 296.0;

class BingoTileCard extends StatelessWidget {
  const BingoTileCard({
    required this.tile,
    required this.isCompleted,
    required this.onTap,
    this.showPoints = false,
    super.key,
  });

  final BingoTile tile;
  final bool isCompleted;
  final VoidCallback onTap;
  final bool showPoints;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileSize = constraints.maxWidth;
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
                TileCompletionOverlay(
                  borderPadding: borderPadding,
                  color: appColors.completedOverlay,
                ),
              if (tile.hasProofs && !isCompleted)
                Positioned.fill(
                  child: Container(
                    margin: EdgeInsets.all(borderPadding * 0.5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: appColors.proofIndicator.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              _BingoTileContent(tile: tile),
              if (showPoints && tile.points > 0)
                Positioned(
                  top: borderPadding * 0.5,
                  right: borderPadding * 0.5,
                  child: _PointsBadge(
                    points: tile.points,
                    color: appColors.warning,
                  ),
                ),
              if (tile.hasProofs && !isCompleted)
                Positioned(
                  bottom: borderPadding * 0.5,
                  left: borderPadding * 0.5,
                  child: _ProofIndicator(color: appColors.proofIndicator),
                ),
            ],
          );
        },
      ),
    );
  }
}

class TileCompletionOverlay extends StatelessWidget {
  const TileCompletionOverlay({
    required this.borderPadding,
    required this.color,
    super.key,
  });

  final double borderPadding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(borderPadding),
      child: Container(color: color.withValues(alpha: 0.2)),
    );
  }
}

class _PointsBadge extends StatelessWidget {
  const _PointsBadge({required this.points, required this.color});

  final int points;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        '$points',
        style: const TextStyle(
          color: Color(0xFF5D4037),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ProofIndicator extends StatelessWidget {
  const _ProofIndicator({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.edit_rounded, size: 12, color: Colors.white),
    );
  }
}

class _BingoTileContent extends StatelessWidget {
  const _BingoTileContent({required this.tile});

  final BingoTile tile;

  @override
  Widget build(BuildContext context) {
    final bossTypeColor = _getBossTypeColor(tile.bossType);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileSize = constraints.maxWidth;
        final iconSize = (tileSize * 0.35).clamp(24.0, 48.0);
        final fontSize = (tileSize * 0.08).clamp(8.0, 11.0);
        final smallFontSize = (tileSize * 0.065).clamp(7.0, 9.0);
        final spacing = tileSize * 0.05;
        final lineMargin = tileSize * 0.2;

        return Padding(
          padding: EdgeInsets.all(tileSize * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (tile.bossIconUrl != null) ...[
                const SizedBox(height: 4),
                CachedNetworkImage(
                  imageUrl: tile.bossIconUrl!,
                  fit: BoxFit.contain,
                  width: iconSize,
                  height: iconSize,
                  placeholder: (context, url) =>
                      SizedBox(width: iconSize, height: iconSize),
                  errorWidget: (context, url, error) => const SizedBox.shrink(),
                ),
                SizedBox(height: spacing),
              ],
              Container(
                height: 1.5,
                margin: EdgeInsets.symmetric(horizontal: lineMargin),
                color: bossTypeColor,
              ),
              Flexible(
                child: _buildUniqueItemsSection(
                  context,
                  fontSize,
                  smallFontSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getBossTypeColor(BossType? type) {
    return switch (type) {
      BossType.easy => const Color(0xFF4CAF50),
      BossType.solo => const Color(0xFF9C27B0),
      BossType.group => const Color(0xFFE11D48),
      BossType.slayer => const Color(0xFFFF9800),
      null => const Color(0xFF4CAF50),
    };
  }

  Widget _buildUniqueItemsSection(
    BuildContext context,
    double fontSize,
    double smallFontSize,
  ) {
    if (tile.isAnyUnique) {
      return Center(
        child: Text(
          'Any unique',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
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
            fontSize: fontSize,
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

    final hasMore = items.length > 4;
    final displayItems = items.take(hasMore ? 3 : 4).toList();

    final headerText = tile.isOrLogic
        ? (tile.anyNCount != null && tile.anyNCount! > 1
              ? 'Any ${tile.anyNCount} of:'
              : 'Any of:')
        : 'All of:';

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              headerText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: smallFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          ...displayItems.map(
            (itemText) => Text(
              itemText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: smallFontSize,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasMore)
            Text(
              '+${items.length - 3} more',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
                fontWeight: FontWeight.w600,
                fontSize: smallFontSize,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
