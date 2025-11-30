import 'package:backend/database.dart' hide TileProof;
import 'package:shared_models/shared_models.dart';

class ActivityService {
  final AppDatabase _db;

  ActivityService(this._db);

  Future<List<TileActivity>> getRecentActivity({
    required String gameId,
    int limit = 50,
  }) async {
    final activities = <TileActivity>[];

    final proofs = await _db.getProofsByGame(gameId);
    final completions = await _db.getCompletedTilesByGame(gameId);
    final tiles = await _db.getTilesByGameId(gameId);
    final teams = await _db.getTeamsByGameId(gameId);
    final bosses = await _db.getAllBosses();

    final tileMap = {for (final t in tiles) t.id: t};
    final teamMap = {for (final t in teams) t.id: t};
    final bossMap = {for (final b in bosses) b.id: b};
    final userCache = <String, User>{};

    Future<User?> getUser(String userId) async {
      if (!userCache.containsKey(userId)) {
        final user = await _db.getUserById(userId);
        if (user != null) userCache[userId] = user;
      }
      return userCache[userId];
    }

    for (final proof in proofs) {
      final user = await getUser(proof.uploadedByUserId);
      final tile = tileMap[proof.tileId];
      final team = teamMap[proof.teamId];
      final boss = tile != null ? bossMap[tile.bossId] : null;

      activities.add(TileActivity(
        id: 'proof_${proof.id}',
        type: ActivityType.proofUploaded,
        userId: proof.uploadedByUserId,
        username: user?.globalName ?? user?.username,
        userAvatar: user?.avatar,
        tileId: proof.tileId,
        tileName: tile?.description ?? boss?.name,
        tileIconUrl: boss?.iconUrl,
        teamId: proof.teamId,
        teamName: team?.name,
        teamColor: team?.color,
        proofImageUrl: proof.imageUrl,
        timestamp: DateTime.parse(proof.uploadedAt),
      ));
    }

    for (final completion in completions) {
      if (completion.completedByUserId == null || completion.completedAt == null) continue;

      final user = await getUser(completion.completedByUserId!);
      final tile = tileMap[completion.tileId];
      final team = teamMap[completion.teamId];
      final boss = tile != null ? bossMap[tile.bossId] : null;

      activities.add(TileActivity(
        id: 'completion_${completion.teamId}_${completion.tileId}',
        type: ActivityType.tileCompleted,
        userId: completion.completedByUserId!,
        username: user?.globalName ?? user?.username,
        userAvatar: user?.avatar,
        tileId: completion.tileId,
        tileName: tile?.description ?? boss?.name,
        tileIconUrl: boss?.iconUrl,
        teamId: completion.teamId,
        teamName: team?.name,
        teamColor: team?.color,
        timestamp: DateTime.parse(completion.completedAt!),
      ));
    }

    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities.take(limit).toList();
  }

  Future<ProofStats> getStats({required String gameId}) async {
    final proofCounts = await _db.getProofCountsByUser(gameId);
    final completionCounts = await _db.getCompletionCountsByUser(gameId);

    final allUserIds = {...proofCounts.keys, ...completionCounts.keys};
    final userCache = <String, User>{};

    for (final userId in allUserIds) {
      final user = await _db.getUserById(userId);
      if (user != null) userCache[userId] = user;
    }

    final topProofUploaders = proofCounts.entries
        .map((e) {
          final user = userCache[e.key];
          return UserStats(
            userId: e.key,
            username: user?.globalName ?? user?.username,
            avatar: user?.avatar,
            count: e.value,
          );
        })
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    final topTileCompleters = completionCounts.entries
        .map((e) {
          final user = userCache[e.key];
          return UserStats(
            userId: e.key,
            username: user?.globalName ?? user?.username,
            avatar: user?.avatar,
            count: e.value,
          );
        })
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));

    return ProofStats(
      topProofUploaders: topProofUploaders.take(10).toList(),
      topTileCompleters: topTileCompleters.take(10).toList(),
      totalProofs: proofCounts.values.fold(0, (sum, count) => sum + count),
      totalCompletions: completionCounts.values.fold(0, (sum, count) => sum + count),
    );
  }
}

