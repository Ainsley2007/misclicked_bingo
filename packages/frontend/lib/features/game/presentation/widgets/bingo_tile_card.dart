import 'package:flutter/material.dart';
import 'package:shared_models/shared_models.dart';
import 'package:frontend/core/constants/color_filters.dart';

enum TileState { locked, unlocked, completed }

class BingoTileCard extends StatelessWidget {
  const BingoTileCard({
    required this.tile,
    required this.state,
    required this.onTap,
    super.key,
  });

  final BingoTile tile;
  final TileState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: state != TileState.locked ? onTap : null,
      child: Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide.none,
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/image/tile.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    ColorFiltered(
                      colorFilter: state == TileState.locked
                          ? ColorFilters.grayscale
                          : ColorFilters.none,
                      child: Image.network(
                        tile.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 50,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      tile.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              if (state == TileState.locked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (state == TileState.completed)
                Positioned(
                  left: 8,
                  right: 8,
                  top: 8,
                  bottom: 8,
                  child: Container(
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
