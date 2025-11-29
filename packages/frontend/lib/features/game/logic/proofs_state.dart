import 'package:equatable/equatable.dart';
import 'package:shared_models/shared_models.dart';

enum ProofsStatus { initial, loading, loaded, uploading, deleting, error }

final class ProofsState extends Equatable {
  final ProofsStatus status;
  final List<TileProof> proofs;
  final String? error;
  final double uploadProgress;
  final int uploadTotal;
  final int uploadCurrent;

  const ProofsState({
    this.status = ProofsStatus.initial,
    this.proofs = const [],
    this.error,
    this.uploadProgress = 0,
    this.uploadTotal = 0,
    this.uploadCurrent = 0,
  });

  const ProofsState.initial() : this();

  const ProofsState.loading() : this(status: ProofsStatus.loading);

  const ProofsState.loaded(List<TileProof> proofs)
      : this(status: ProofsStatus.loaded, proofs: proofs);

  const ProofsState.uploading(List<TileProof> proofs, {int total = 1, int current = 1})
      : this(status: ProofsStatus.uploading, proofs: proofs, uploadTotal: total, uploadCurrent: current);

  const ProofsState.deleting(List<TileProof> proofs)
      : this(status: ProofsStatus.deleting, proofs: proofs);

  const ProofsState.error(String message, List<TileProof> proofs)
      : this(status: ProofsStatus.error, proofs: proofs, error: message);

  ProofsState copyWith({
    ProofsStatus? status,
    List<TileProof>? proofs,
    String? error,
    double? uploadProgress,
    int? uploadTotal,
    int? uploadCurrent,
  }) {
    return ProofsState(
      status: status ?? this.status,
      proofs: proofs ?? this.proofs,
      error: error ?? this.error,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadTotal: uploadTotal ?? this.uploadTotal,
      uploadCurrent: uploadCurrent ?? this.uploadCurrent,
    );
  }

  bool get canComplete => proofs.isNotEmpty;

  @override
  List<Object?> get props => [status, proofs, error, uploadProgress, uploadTotal, uploadCurrent];
}

