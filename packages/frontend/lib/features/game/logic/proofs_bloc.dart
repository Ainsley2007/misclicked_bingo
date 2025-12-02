import 'dart:typed_data';

import 'package:frontend/core/bloc/base_bloc.dart';
import 'package:frontend/repositories/proofs_repository.dart';
import 'package:frontend/features/game/logic/proofs_event.dart';
import 'package:frontend/features/game/logic/proofs_state.dart';
import 'package:shared_models/shared_models.dart';

class ProofsBloc extends BaseBloc<ProofsEvent, ProofsState> {
  ProofsBloc(this._repository) : super(const ProofsState.initial()) {
    on<ProofsLoadRequested>(_onLoadRequested);
    onDroppable<ProofUploadRequested>(_onUploadRequested);
    onDroppable<ProofsBatchUploadRequested>(_onBatchUploadRequested);
    onDroppable<ProofDeleteRequested>(_onDeleteRequested);
    on<ProofsCleared>(_onCleared);
  }

  final ProofsRepository _repository;

  Future<void> _onLoadRequested(ProofsLoadRequested event, Emitter<ProofsState> emit) async {
    emit(const ProofsState.loading());
    await executeWithResult(
      action: () => _repository.getProofs(gameId: event.gameId, tileId: event.tileId, teamId: event.teamId),
      onSuccess: (proofs) => emit(ProofsState.loaded(proofs)),
      onError: (message) => emit(ProofsState.error(message, state.proofs)),
      context: 'proofs',
      defaultMessage: 'Failed to load proofs',
    );
  }

  Future<void> _onUploadRequested(ProofUploadRequested event, Emitter<ProofsState> emit) async {
    if (!_repository.isValidImageFile(event.fileName)) {
      emit(ProofsState.error('Invalid file type. Only JPG, PNG, GIF, and WebP are allowed.', state.proofs));
      return;
    }

    if (!_repository.isValidFileSize(event.fileBytes.length)) {
      emit(ProofsState.error('File is too large. Maximum size is 5MB.', state.proofs));
      return;
    }

    if (state.proofs.length >= 10) {
      emit(ProofsState.error('Maximum of 10 proofs per tile.', state.proofs));
      return;
    }

    emit(ProofsState.uploading(state.proofs));
    await executeWithResult(
      action: () {
        final contentType = _repository.getContentType(event.fileName);
        return _repository.uploadProof(gameId: event.gameId, tileId: event.tileId, fileName: event.fileName, fileBytes: event.fileBytes, contentType: contentType);
      },
      onSuccess: (proof) => emit(ProofsState.loaded([...state.proofs, proof])),
      onError: (message) => emit(ProofsState.error('Upload failed: $message', state.proofs)),
      context: 'proofs',
      defaultMessage: 'Failed to upload proof',
    );
  }

  Future<void> _onBatchUploadRequested(ProofsBatchUploadRequested event, Emitter<ProofsState> emit) async {
    final originalProofs = List<TileProof>.from(state.proofs);
    final validFiles = <({String fileName, List<int> fileBytes, String contentType})>[];

    for (final file in event.files) {
      if (!_repository.isValidImageFile(file.fileName)) continue;
      if (!_repository.isValidFileSize(file.fileBytes.length)) continue;
      if (originalProofs.length + validFiles.length >= 10) break;

      validFiles.add((fileName: file.fileName, fileBytes: file.fileBytes, contentType: _repository.getContentType(file.fileName)));
    }

    if (validFiles.isEmpty) {
      emit(ProofsState.error('No valid files to upload. Check file types and sizes.', originalProofs));
      return;
    }

    final uploadedProofs = <TileProof>[];

    for (var i = 0; i < validFiles.length; i++) {
      final file = validFiles[i];
      emit(ProofsState.uploading([...originalProofs, ...uploadedProofs], total: validFiles.length, current: i + 1));

      final proof = await executeWithResult<TileProof>(
        action: () => _repository.uploadProof(
          gameId: event.gameId,
          tileId: event.tileId,
          fileName: file.fileName,
          fileBytes: Uint8List.fromList(file.fileBytes),
          contentType: file.contentType,
        ),
        onSuccess: (_) {},
        onError: (message) => emit(ProofsState.error('Failed to upload ${file.fileName}: $message', [...originalProofs, ...uploadedProofs])),
        context: 'proofs',
        defaultMessage: 'Failed to upload file',
      );

      if (proof == null) return;
      uploadedProofs.add(proof);
    }

    emit(ProofsState.loaded([...originalProofs, ...uploadedProofs]));
  }

  Future<void> _onDeleteRequested(ProofDeleteRequested event, Emitter<ProofsState> emit) async {
    emit(ProofsState.deleting(state.proofs));
    await execute(
      action: () async {
        await _repository.deleteProof(gameId: event.gameId, tileId: event.tileId, proofId: event.proofId);
        final updatedProofs = state.proofs.where((p) => p.id != event.proofId).toList();
        emit(ProofsState.loaded(updatedProofs));
      },
      onError: (message) => emit(ProofsState.error('Delete failed: $message', state.proofs)),
      context: 'proofs',
      defaultMessage: 'Failed to delete proof',
    );
  }

  void _onCleared(ProofsCleared event, Emitter<ProofsState> emit) {
    emit(const ProofsState.initial());
  }
}
