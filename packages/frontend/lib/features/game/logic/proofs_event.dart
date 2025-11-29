import 'dart:typed_data';

import 'package:equatable/equatable.dart';

sealed class ProofsEvent extends Equatable {
  const ProofsEvent();

  @override
  List<Object?> get props => [];
}

final class ProofsLoadRequested extends ProofsEvent {
  final String gameId;
  final String tileId;

  const ProofsLoadRequested({required this.gameId, required this.tileId});

  @override
  List<Object?> get props => [gameId, tileId];
}

final class ProofUploadRequested extends ProofsEvent {
  final String gameId;
  final String tileId;
  final String fileName;
  final Uint8List fileBytes;

  const ProofUploadRequested({
    required this.gameId,
    required this.tileId,
    required this.fileName,
    required this.fileBytes,
  });

  @override
  List<Object?> get props => [gameId, tileId, fileName];
}

final class ProofsBatchUploadRequested extends ProofsEvent {
  final String gameId;
  final String tileId;
  final List<({String fileName, Uint8List fileBytes})> files;

  const ProofsBatchUploadRequested({
    required this.gameId,
    required this.tileId,
    required this.files,
  });

  @override
  List<Object?> get props => [gameId, tileId, files.length];
}

final class ProofDeleteRequested extends ProofsEvent {
  final String gameId;
  final String tileId;
  final String proofId;

  const ProofDeleteRequested({
    required this.gameId,
    required this.tileId,
    required this.proofId,
  });

  @override
  List<Object?> get props => [gameId, tileId, proofId];
}

final class ProofsCleared extends ProofsEvent {
  const ProofsCleared();
}

