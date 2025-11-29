import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:frontend/core/api/proofs_api.dart';
import 'package:shared_models/shared_models.dart';

class ProofsRepository {
  final ProofsApi _api;

  ProofsRepository(this._api);

  Future<List<TileProof>> getProofs({
    required String gameId,
    required String tileId,
    String? teamId,
  }) async {
    return _api.getProofs(gameId, tileId, teamId);
  }

  Future<TileProof> uploadProof({
    required String gameId,
    required String tileId,
    required String fileName,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    final presignedResponse = await _api.getUploadUrl(
      UploadUrlRequest(gameId: gameId, fileName: fileName),
    );

    await _uploadToR2(
      uploadUrl: presignedResponse.uploadUrl,
      fileBytes: fileBytes,
      contentType: contentType,
    );

    final proof = await _api.createProof(
      gameId,
      tileId,
      CreateProofRequest(imageUrl: presignedResponse.publicUrl),
    );

    return proof;
  }

  Future<void> _uploadToR2({
    required String uploadUrl,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    final uploadDio = Dio();
    await uploadDio.put<void>(
      uploadUrl,
      data: Stream.fromIterable([fileBytes]),
      options: Options(
        headers: {
          'Content-Type': contentType,
          'Content-Length': fileBytes.length,
        },
      ),
    );
  }

  Future<void> deleteProof({
    required String gameId,
    required String tileId,
    required String proofId,
  }) async {
    await _api.deleteProof(gameId, tileId, proofId);
  }

  Future<List<TileActivity>> getActivity({
    required String gameId,
    int? limit,
  }) async {
    return _api.getActivity(gameId, limit);
  }

  Future<ProofStats> getStats({required String gameId}) async {
    return _api.getStats(gameId);
  }

  bool isValidImageFile(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  bool isValidFileSize(int bytes) {
    const maxSize = 5 * 1024 * 1024;
    return bytes <= maxSize;
  }

  String getContentType(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }
}

