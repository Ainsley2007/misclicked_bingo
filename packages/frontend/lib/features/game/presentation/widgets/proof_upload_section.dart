import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/game/logic/proofs_bloc.dart';
import 'package:frontend/features/game/logic/proofs_event.dart';
import 'package:frontend/features/game/logic/proofs_state.dart';
import 'package:intl/intl.dart';
import 'package:shared_models/shared_models.dart';
import 'package:super_clipboard/super_clipboard.dart';

class ProofUploadSection extends StatefulWidget {
  final String gameId;
  final String tileId;
  final bool isCompleted;

  const ProofUploadSection({
    required this.gameId,
    required this.tileId,
    this.isCompleted = false,
    super.key,
  });

  @override
  State<ProofUploadSection> createState() => _ProofUploadSectionState();
}

class _ProofUploadSectionState extends State<ProofUploadSection> {
  bool _isDragging = false;
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProofsBloc, ProofsState>(
      builder: (context, state) {
        final canUpload = !widget.isCompleted && state.proofs.length < 10;

        return Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: canUpload ? _handleKeyEvent : null,
          child: GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 12),
                if (state.proofs.isNotEmpty) ...[
                  _buildProofGallery(context, state),
                  const SizedBox(height: 12),
                ],
                if (canUpload) _buildDropZone(context, state),
                if (widget.isCompleted && state.proofs.isEmpty)
                  _buildCompletedEmptyState(context),
                if (state.status == ProofsStatus.error &&
                    state.error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.keyV &&
        (HardwareKeyboard.instance.isControlPressed ||
            HardwareKeyboard.instance.isMetaPressed)) {
      _handlePaste();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _handlePaste() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) return;

    final reader = await clipboard.read();

    final formats = <(SimpleFileFormat, String)>[
      (Formats.png, 'png'),
      (Formats.jpeg, 'jpg'),
      (Formats.gif, 'gif'),
      (Formats.webp, 'webp'),
    ];

    for (final (format, extension) in formats) {
      if (reader.canProvide(format)) {
        reader.getFile(format, (file) async {
          final stream = file.getStream();
          final chunks = <List<int>>[];
          await for (final chunk in stream) {
            chunks.add(chunk);
          }
          final bytes = Uint8List.fromList(chunks.expand((x) => x).toList());
          final fileName =
              'pasted_${DateTime.now().millisecondsSinceEpoch}.$extension';
          _uploadFile(fileName, bytes);
        });
        return;
      }
    }
  }

  Widget _buildHeader(BuildContext context, ProofsState state) {
    return Row(
      children: [
        Text(
          'Proof Screenshots',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: state.proofs.isEmpty
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${state.proofs.length}/10',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: state.proofs.isEmpty
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        if (widget.isCompleted) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 12, color: Color(0xFF4CAF50)),
                SizedBox(width: 4),
                Text(
                  'Locked',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProofGallery(BuildContext context, ProofsState state) {
    final isDeleting = state.status == ProofsStatus.deleting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...state.proofs.map(
          (proof) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ProofRow(
              proof: proof,
              gameId: widget.gameId,
              tileId: widget.tileId,
              canDelete: !widget.isCompleted && !isDeleting,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No screenshots were uploaded for this tile.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone(BuildContext context, ProofsState state) {
    final isUploading = state.status == ProofsStatus.uploading;

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (details) {
        setState(() => _isDragging = false);
        _handleDroppedFiles(details.files);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _isDragging
              ? Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isDragging
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: _isDragging ? 2 : 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          children: [
            if (isUploading) ...[
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(height: 8),
              Text(
                state.uploadTotal > 1
                    ? 'Uploading ${state.uploadCurrent}/${state.uploadTotal}...'
                    : 'Uploading...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else ...[
              Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'Drop, paste, or',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _pickFiles,
                icon: const Icon(Icons.folder_open, size: 18),
                label: const Text('Browse files'),
              ),
              const SizedBox(height: 4),
              Text(
                'JPG, PNG, GIF, WebP • Max 5MB • Ctrl+V to paste',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final files = result.files
          .where((f) => f.bytes != null && f.name.isNotEmpty)
          .map((f) => (fileName: f.name, fileBytes: f.bytes!))
          .toList();

      if (files.length == 1) {
        _uploadFile(files.first.fileName, files.first.fileBytes);
      } else if (files.isNotEmpty) {
        _uploadFiles(files);
      }
    }
  }

  Future<void> _handleDroppedFiles(List<dynamic> files) async {
    if (files.isEmpty) return;

    final fileData = <({String fileName, Uint8List fileBytes})>[];

    for (final file in files) {
      final bytes = await file.readAsBytes() as Uint8List;
      final name = file.name as String;
      fileData.add((fileName: name, fileBytes: bytes));
    }

    if (fileData.length == 1) {
      _uploadFile(fileData.first.fileName, fileData.first.fileBytes);
    } else if (fileData.isNotEmpty) {
      _uploadFiles(fileData);
    }
  }

  void _uploadFile(String fileName, Uint8List bytes) {
    context.read<ProofsBloc>().add(
      ProofUploadRequested(
        gameId: widget.gameId,
        tileId: widget.tileId,
        fileName: fileName,
        fileBytes: bytes,
      ),
    );
  }

  void _uploadFiles(List<({String fileName, Uint8List fileBytes})> files) {
    context.read<ProofsBloc>().add(
      ProofsBatchUploadRequested(
        gameId: widget.gameId,
        tileId: widget.tileId,
        files: files,
      ),
    );
  }
}

class _ProofRow extends StatelessWidget {
  final TileProof proof;
  final String gameId;
  final String tileId;
  final bool canDelete;

  const _ProofRow({
    required this.proof,
    required this.gameId,
    required this.tileId,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _openFullImage(context),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  proof.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.errorContainer,
                      child: Icon(
                        Icons.broken_image,
                        size: 20,
                        color: colorScheme.onErrorContainer,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        proof.uploadedByUsername ?? 'Unknown',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(proof.uploadedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _openFullImage(context),
            icon: Icon(
              Icons.open_in_new,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: 'View full size',
            visualDensity: VisualDensity.compact,
          ),
          if (canDelete)
            IconButton(
              onPressed: () => _confirmDelete(context),
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: colorScheme.error,
              ),
              tooltip: 'Delete proof',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final bloc = context.read<ProofsBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Proof?'),
        content: const Text(
          'This will permanently delete this screenshot. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              bloc.add(
                ProofDeleteRequested(
                  gameId: gameId,
                  tileId: tileId,
                  proofId: proof.id,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(proof.imageUrl),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y • h:mm a').format(date);
  }
}
