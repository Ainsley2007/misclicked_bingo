import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/features/game/logic/proofs_bloc.dart';
import 'package:frontend/features/game/logic/proofs_event.dart';
import 'package:frontend/features/game/logic/proofs_state.dart';
import 'package:frontend/features/game/presentation/widgets/proof_upload_section.dart';
import 'package:frontend/theme/app_dimens.dart';
import 'package:shared_models/shared_models.dart';

class TileDetailsDialog extends StatelessWidget {
  const TileDetailsDialog({
    required this.tile,
    required this.gameId,
    required this.onToggleCompletion,
    this.onProofsChanged,
    this.gameStartTime,
    this.gameEndTime,
    super.key,
  });

  final BingoTile tile;
  final String gameId;
  final void Function(bool canComplete) onToggleCompletion;
  final void Function(bool hasProofs)? onProofsChanged;
  final DateTime? gameStartTime;
  final DateTime? gameEndTime;

  @override
  Widget build(BuildContext context) {
    final authService = sl<AuthService>();
    final user = authService.currentUser;
    final canUndoCompletion =
        user?.role == UserRole.admin || user?.role == UserRole.captain;

    return BlocProvider(
      create: (_) =>
          sl<ProofsBloc>()
            ..add(ProofsLoadRequested(gameId: gameId, tileId: tile.id)),
      child: _TileDetailsDialogContent(
        tile: tile,
        gameId: gameId,
        onToggleCompletion: onToggleCompletion,
        onProofsChanged: onProofsChanged,
        canUndoCompletion: canUndoCompletion,
        gameStartTime: gameStartTime,
        gameEndTime: gameEndTime,
      ),
    );
  }
}

class _TileDetailsDialogContent extends StatefulWidget {
  const _TileDetailsDialogContent({
    required this.tile,
    required this.gameId,
    required this.onToggleCompletion,
    required this.canUndoCompletion,
    this.onProofsChanged,
    this.gameStartTime,
    this.gameEndTime,
  });

  final BingoTile tile;
  final String gameId;
  final void Function(bool canComplete) onToggleCompletion;
  final void Function(bool hasProofs)? onProofsChanged;
  final bool canUndoCompletion;
  final DateTime? gameStartTime;
  final DateTime? gameEndTime;

  @override
  State<_TileDetailsDialogContent> createState() =>
      _TileDetailsDialogContentState();
}

class _TileDetailsDialogContentState extends State<_TileDetailsDialogContent> {
  bool? _currentHasProofs;

  bool get _hasGameStarted =>
      widget.gameStartTime == null ||
      DateTime.now().isAfter(widget.gameStartTime!);
  bool get _hasGameEnded =>
      widget.gameEndTime != null && DateTime.now().isAfter(widget.gameEndTime!);
  bool get _canModifyTile => _hasGameStarted && !_hasGameEnded;

  void _handleClose() {
    if (_currentHasProofs != null &&
        _currentHasProofs != widget.tile.hasProofs) {
      widget.onProofsChanged?.call(_currentHasProofs!);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bossTypeColor = _getBossTypeColor(widget.tile.bossType);

    return BlocListener<ProofsBloc, ProofsState>(
      listener: (context, state) {
        if (state.status == ProofsStatus.loaded) {
          _currentHasProofs = state.proofs.isNotEmpty;
        }
        if (state.status == ProofsStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusM),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550, maxHeight: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimens.paddingL),
                    child: Column(
                      children: [
                        if (widget.tile.bossIconUrl != null) ...[
                          Image.network(
                            widget.tile.bossIconUrl!,
                            fit: BoxFit.contain,
                            width: 96,
                            height: 96,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                          const SizedBox(height: AppDimens.paddingM),
                        ],
                        Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 60),
                          color: bossTypeColor,
                        ),
                        const SizedBox(height: AppDimens.paddingL),
                        Text(
                          widget.tile.description ??
                              widget.tile.bossName ??
                              'Unknown Boss',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        if (widget.tile.bossName != null &&
                            widget.tile.description != null) ...[
                          const SizedBox(height: AppDimens.paddingS),
                          Text(
                            widget.tile.bossName!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: AppDimens.paddingL),
                        _buildUniqueItemsSection(context),
                        const SizedBox(height: AppDimens.paddingL),
                        ProofUploadSection(
                          gameId: widget.gameId,
                          tileId: widget.tile.id,
                          isCompleted: widget.tile.isCompleted,
                          gameStartTime: widget.gameStartTime,
                          gameEndTime: widget.gameEndTime,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return BlocBuilder<ProofsBloc, ProofsState>(
      builder: (context, state) {
        final canComplete = state.canComplete && _canModifyTile;
        final isLoading =
            state.status == ProofsStatus.loading ||
            state.status == ProofsStatus.uploading;

        String? disabledReason;
        if (!_hasGameStarted) {
          disabledReason = 'Game has not started yet';
        } else if (_hasGameEnded) {
          disabledReason = 'Game has ended';
        } else if (!state.canComplete) {
          disabledReason = 'Add Proof First';
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_canModifyTile)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingL,
                  vertical: AppDimens.paddingS + AppDimens.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.4),
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      !_hasGameStarted
                          ? Icons.schedule_rounded
                          : Icons.timer_off_rounded,
                      size: AppDimens.iconSizeM,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(
                      width: AppDimens.paddingS + AppDimens.paddingXS,
                    ),
                    Expanded(
                      child: Text(
                        !_hasGameStarted
                            ? 'Game has not started yet. You cannot complete tiles until it starts.'
                            : 'Game has ended. Tiles can no longer be completed.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.all(AppDimens.paddingL),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: AppDimens.paddingS + AppDimens.paddingXS,
                children: [
                  _buildButton(
                    context: context,
                    label: 'Close',
                    onPressed: _handleClose,
                    isPrimary: false,
                  ),
                  if (widget.tile.isCompleted &&
                      widget.canUndoCompletion &&
                      _canModifyTile)
                    _buildButton(
                      context: context,
                      label: 'Undo Completion',
                      onPressed: () {
                        widget.onToggleCompletion(true);
                        _handleClose();
                      },
                      isPrimary: false,
                    ),
                  if (!widget.tile.isCompleted)
                    _buildButton(
                      context: context,
                      label: disabledReason ?? 'Mark Complete',
                      onPressed: canComplete && !isLoading
                          ? () {
                              widget.onToggleCompletion(true);
                              _handleClose();
                            }
                          : null,
                      isPrimary: true,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          foregroundColor: onPressed != null
              ? colorScheme.onPrimary
              : colorScheme.onSurface.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingL,
            vertical: AppDimens.paddingS + 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusS),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      );
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.onSurface.withValues(alpha: 0.7),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingL - AppDimens.paddingXS,
          vertical: AppDimens.paddingS + 6,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusS),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
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

  Widget _buildUniqueItemsSection(BuildContext context) {
    if (widget.tile.isAnyUnique) {
      final uniqueItems = widget.tile.possibleUniqueItems;
      return Container(
        padding: const EdgeInsets.all(AppDimens.paddingM),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusM),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Any unique',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: AppDimens.paddingS),
            Text(
              'Any unique item from ${widget.tile.bossName ?? "this boss"}\'s drop table:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimens.paddingM),
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
                  padding: const EdgeInsets.only(bottom: AppDimens.paddingS),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: AppDimens.paddingS),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(
                        width: AppDimens.paddingS + AppDimens.paddingXS,
                      ),
                      Expanded(
                        child: Text(
                          itemName,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 14, height: 1.5),
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

    if (widget.tile.uniqueItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusM),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.tile.isOrLogic
                ? (widget.tile.anyNCount != null && widget.tile.anyNCount! > 1
                      ? 'Any ${widget.tile.anyNCount} of:'
                      : 'Any of:')
                : 'All of:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppDimens.paddingM),
          ...widget.tile.uniqueItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.paddingS),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: AppDimens.paddingS),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(
                    width: AppDimens.paddingS + AppDimens.paddingXS,
                  ),
                  Expanded(
                    child: Text(
                      item.itemName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  if (item.requiredCount > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.paddingS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppDimens.borderRadiusS,
                        ),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        'x${item.requiredCount}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
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
