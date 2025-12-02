import 'package:backend/database.dart' hide TileProof;
import 'package:backend/services/r2_service.dart';
import 'package:shared_models/shared_models.dart';
import 'package:uuid/uuid.dart';

class ProofsService {

  ProofsService(this._db, this._r2);
  final AppDatabase _db;
  final R2Service _r2;
  static const _uuid = Uuid();

  Future<Map<String, String>> getPresignedUploadUrl({
    required String gameId,
    required String teamId,
    required String fileName,
  }) async {
    final objectKey = _r2.generateObjectKey(
      gameId: gameId,
      teamId: teamId,
      fileName: fileName,
    );
    final uploadUrl = await _r2.generatePresignedUploadUrl(objectKey: objectKey);
    final publicUrl = _r2.getPublicUrl(objectKey);

    return {
      'uploadUrl': uploadUrl,
      'publicUrl': publicUrl,
      'objectKey': objectKey,
    };
  }

  Future<TileProof> createProof({
    required String teamId,
    required String tileId,
    required String imageUrl,
    required String uploadedByUserId,
  }) async {
    final id = _uuid.v4();
    final uploadedAt = DateTime.now();

    await _db.createTileProof(
      id: id,
      teamId: teamId,
      tileId: tileId,
      imageUrl: imageUrl,
      uploadedByUserId: uploadedByUserId,
      uploadedAt: uploadedAt,
    );

    final user = await _db.getUserById(uploadedByUserId);

    return TileProof(
      id: id,
      teamId: teamId,
      tileId: tileId,
      imageUrl: imageUrl,
      uploadedByUserId: uploadedByUserId,
      uploadedByUsername: user?.globalName ?? user?.username,
      uploadedAt: uploadedAt,
    );
  }

  Future<List<TileProof>> getProofsForTile({
    required String tileId,
    required String teamId,
  }) async {
    final proofs = await _db.getProofsByTileAndTeam(tileId: tileId, teamId: teamId);
    final userIds = proofs.map((p) => p.uploadedByUserId).toSet();
    final users = <String, User>{};

    for (final userId in userIds) {
      final user = await _db.getUserById(userId);
      if (user != null) users[userId] = user;
    }

    return proofs.map((p) {
      final user = users[p.uploadedByUserId];
      return TileProof(
        id: p.id,
        teamId: p.teamId,
        tileId: p.tileId,
        imageUrl: p.imageUrl,
        uploadedByUserId: p.uploadedByUserId,
        uploadedByUsername: user?.globalName ?? user?.username,
        uploadedAt: DateTime.parse(p.uploadedAt),
      );
    }).toList();
  }

  Future<int> getProofCount({
    required String tileId,
    required String teamId,
  }) async {
    return _db.getProofCountByTileAndTeam(tileId: tileId, teamId: teamId);
  }

  Future<void> deleteProof(String proofId) async {
    await _db.deleteTileProof(proofId);
  }
}

