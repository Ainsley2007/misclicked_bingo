import 'package:backend/database.dart';

class TileCompletionResult {
  final bool success;
  final String? error;
  final String? status;

  TileCompletionResult.success(this.status) : success = true, error = null;
  TileCompletionResult.failure(this.error) : success = false, status = null;
}

class TilesService {
  final AppDatabase _db;

  TilesService(this._db);

  Future<TileCompletionResult> completeTile({
    required String tileId,
    required String teamId,
    required String userId,
  }) async {
    final proofCount = await _db.getProofCountByTileAndTeam(
      tileId: tileId,
      teamId: teamId,
    );

    if (proofCount < 1) {
      return TileCompletionResult.failure(
        'At least 1 proof screenshot is required to complete a tile',
      );
    }

    await _db.setTeamBoardState(
      teamId: teamId,
      tileId: tileId,
      status: 'completed',
      completedByUserId: userId,
      completedAt: DateTime.now(),
    );

    return TileCompletionResult.success('completed');
  }

  Future<TileCompletionResult> uncompleteTile({
    required String tileId,
    required String teamId,
  }) async {
    await _db.setTeamBoardState(
      teamId: teamId,
      tileId: tileId,
      status: 'incomplete',
      completedByUserId: null,
      completedAt: null,
    );

    return TileCompletionResult.success('incomplete');
  }

  Future<TileCompletionResult> toggleTileCompletion({
    required String tileId,
    required String teamId,
    required String userId,
  }) async {
    final currentState = await _db.getTeamBoardStateData(
      teamId: teamId,
      tileId: tileId,
    );

    if (currentState?.status == 'completed') {
      return uncompleteTile(tileId: tileId, teamId: teamId);
    } else {
      return completeTile(tileId: tileId, teamId: teamId, userId: userId);
    }
  }
}

