import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/game/data/proofs_repository.dart';
import 'package:frontend/features/game/logic/proofs_event.dart';
import 'package:frontend/features/game/logic/proofs_state.dart';
import 'package:shared_models/shared_models.dart';

class ProofsBloc extends Bloc<ProofsEvent, ProofsState> {
  final ProofsRepository _repository;

  ProofsBloc(this._repository) : super(const ProofsState.initial()) {
    on<ProofsLoadRequested>(_onLoadRequested);
    on<ProofUploadRequested>(_onUploadRequested);
    on<ProofsBatchUploadRequested>(_onBatchUploadRequested);
    on<ProofDeleteRequested>(_onDeleteRequested);
    on<ProofsCleared>(_onCleared);
  }

  Future<void> _onLoadRequested(
    ProofsLoadRequested event,
    Emitter<ProofsState> emit,
  ) async {
    emit(const ProofsState.loading());
    try {
      final proofs = await _repository.getProofs(
        gameId: event.gameId,
        tileId: event.tileId,
        teamId: event.teamId,
      );
      emit(ProofsState.loaded(proofs));
    } catch (e) {
      emit(ProofsState.error(e.toString(), state.proofs));
    }
  }

  Future<void> _onUploadRequested(
    ProofUploadRequested event,
    Emitter<ProofsState> emit,
  ) async {
    if (!_repository.isValidImageFile(event.fileName)) {
      emit(
        ProofsState.error(
          'Invalid file type. Only JPG, PNG, GIF, and WebP are allowed.',
          state.proofs,
        ),
      );
      return;
    }

    if (!_repository.isValidFileSize(event.fileBytes.length)) {
      emit(
        ProofsState.error(
          'File is too large. Maximum size is 5MB.',
          state.proofs,
        ),
      );
      return;
    }

    if (state.proofs.length >= 10) {
      emit(ProofsState.error('Maximum of 10 proofs per tile.', state.proofs));
      return;
    }

    emit(ProofsState.uploading(state.proofs));
    try {
      final contentType = _repository.getContentType(event.fileName);
      final proof = await _repository.uploadProof(
        gameId: event.gameId,
        tileId: event.tileId,
        fileName: event.fileName,
        fileBytes: event.fileBytes,
        contentType: contentType,
      );
      emit(ProofsState.loaded([...state.proofs, proof]));
    } catch (e) {
      emit(ProofsState.error('Upload failed: ${e.toString()}', state.proofs));
    }
  }

  Future<void> _onBatchUploadRequested(
    ProofsBatchUploadRequested event,
    Emitter<ProofsState> emit,
  ) async {
    final originalProofs = List<TileProof>.from(state.proofs);
    final validFiles =
        <({String fileName, List<int> fileBytes, String contentType})>[];

    for (final file in event.files) {
      if (!_repository.isValidImageFile(file.fileName)) continue;
      if (!_repository.isValidFileSize(file.fileBytes.length)) continue;
      if (originalProofs.length + validFiles.length >= 10) break;

      validFiles.add((
        fileName: file.fileName,
        fileBytes: file.fileBytes,
        contentType: _repository.getContentType(file.fileName),
      ));
    }

    if (validFiles.isEmpty) {
      emit(
        ProofsState.error(
          'No valid files to upload. Check file types and sizes.',
          originalProofs,
        ),
      );
      return;
    }

    final uploadedProofs = <TileProof>[];

    for (var i = 0; i < validFiles.length; i++) {
      final file = validFiles[i];
      emit(
        ProofsState.uploading(
          [...originalProofs, ...uploadedProofs],
          total: validFiles.length,
          current: i + 1,
        ),
      );

      try {
        final proof = await _repository.uploadProof(
          gameId: event.gameId,
          tileId: event.tileId,
          fileName: file.fileName,
          fileBytes: Uint8List.fromList(file.fileBytes),
          contentType: file.contentType,
        );
        uploadedProofs.add(proof);
      } catch (e) {
        emit(
          ProofsState.error(
            'Failed to upload ${file.fileName}: ${e.toString()}',
            [...originalProofs, ...uploadedProofs],
          ),
        );
        return;
      }
    }

    emit(ProofsState.loaded([...originalProofs, ...uploadedProofs]));
  }

  Future<void> _onDeleteRequested(
    ProofDeleteRequested event,
    Emitter<ProofsState> emit,
  ) async {
    emit(ProofsState.deleting(state.proofs));
    try {
      await _repository.deleteProof(
        gameId: event.gameId,
        tileId: event.tileId,
        proofId: event.proofId,
      );
      final updatedProofs = state.proofs
          .where((p) => p.id != event.proofId)
          .toList();
      emit(ProofsState.loaded(updatedProofs));
    } catch (e) {
      emit(ProofsState.error('Delete failed: ${e.toString()}', state.proofs));
    }
  }

  void _onCleared(ProofsCleared event, Emitter<ProofsState> emit) {
    emit(const ProofsState.initial());
  }
}
