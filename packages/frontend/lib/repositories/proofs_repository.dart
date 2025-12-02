import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:frontend/api/proofs_api.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:shared_models/shared_models.dart';

class ProofsRepository {
  ProofsRepository(this._api);

  final ProofsApi _api;

  Future<List<TileProof>> getProofs({required String gameId, required String tileId, String? teamId}) async {
    try {
      return await _api.getProofs(gameId, tileId, teamId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<TileProof> uploadProof({required String gameId, required String tileId, required String fileName, required Uint8List fileBytes, required String contentType}) async {
    try {
      final presignedResponse = await _api.getUploadUrl(UploadUrlRequest(gameId: gameId, fileName: fileName));

      await _uploadToR2(uploadUrl: presignedResponse.uploadUrl, fileBytes: fileBytes, contentType: contentType);

      return await _api.createProof(gameId, tileId, CreateProofRequest(imageUrl: presignedResponse.publicUrl));
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<void> _uploadToR2({required String uploadUrl, required Uint8List fileBytes, required String contentType}) async {
    final uploadDio = Dio();
    await uploadDio.put<void>(
      uploadUrl,
      data: Stream.fromIterable([fileBytes]),
      options: Options(headers: {'Content-Type': contentType, 'Content-Length': fileBytes.length}),
    );
  }

  Future<void> deleteProof({required String gameId, required String tileId, required String proofId}) async {
    try {
      await _api.deleteProof(gameId, tileId, proofId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
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

  Future<List<TileProof>> getPublicProofs({required String gameId, required String tileId, required String teamId}) async {
    try {
      return await _api.getProofs(gameId, tileId, teamId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }
}
