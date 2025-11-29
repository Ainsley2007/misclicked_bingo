import 'dart:convert';
import 'dart:developer' as developer;
import 'package:backend/config.dart';
import 'package:backend/data/bosses.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:shared_models/shared_models.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get discordId => text().unique()();
  TextColumn get globalName => text().nullable()();
  TextColumn get username => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get avatar => text().nullable()();
  TextColumn get role => text().withDefault(const Constant('user'))();
  TextColumn get teamId => text().nullable()();
  TextColumn get gameId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Games extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  IntColumn get teamSize => integer().withDefault(const Constant(5))();
  IntColumn get boardSize => integer().withDefault(const Constant(3))();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Teams extends Table {
  TextColumn get id => text()();
  TextColumn get gameId => text()();
  TextColumn get name => text()();
  TextColumn get captainUserId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class TeamMembers extends Table {
  TextColumn get teamId => text()();
  TextColumn get userId => text()();

  @override
  Set<Column> get primaryKey => {teamId, userId};
}

class Bosses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get iconUrl => text()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class BossUniqueItems extends Table {
  TextColumn get bossId => text()();
  TextColumn get itemName => text()();

  @override
  Set<Column> get primaryKey => {bossId, itemName};
}

class BingoTiles extends Table {
  TextColumn get id => text()();
  TextColumn get gameId => text()();
  TextColumn get bossId => text()();
  TextColumn get description => text().nullable()();
  IntColumn get position => integer()();
  BoolColumn get isAnyUnique => boolean().withDefault(const Constant(false))();
  BoolColumn get isOrLogic => boolean().withDefault(const Constant(false))();
  IntColumn get anyNCount => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TileUniqueItems extends Table {
  TextColumn get tileId => text()();
  TextColumn get itemName => text()();
  IntColumn get requiredCount => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {tileId, itemName};
}

class TeamBoardState extends Table {
  TextColumn get teamId => text()();
  TextColumn get tileId => text()();
  TextColumn get status => text()();
  TextColumn get completedByUserId => text().nullable()();
  TextColumn get completedAt => text().nullable()();

  @override
  Set<Column> get primaryKey => {teamId, tileId};
}

class TileProofs extends Table {
  TextColumn get id => text()();
  TextColumn get teamId => text()();
  TextColumn get tileId => text()();
  TextColumn get imageUrl => text()();
  TextColumn get uploadedByUserId => text()();
  TextColumn get uploadedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Users,
    Games,
    Teams,
    TeamMembers,
    Bosses,
    BossUniqueItems,
    BingoTiles,
    TileUniqueItems,
    TeamBoardState,
    TileProofs,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    final dbPath = Config.dbPath;
    return NativeDatabase.opened(sqlite3.open(dbPath));
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_users_discord_id ON users(discord_id)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_games_code ON games(code)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_teams_game_id ON teams(game_id)',
      );
      await seedBosses();
    },
  );

  Future<List<Game>> getAllGames() async {
    final query = select(games)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    return query.get();
  }

  Future<Game?> getGameByCode(String code) async {
    final query = select(games)..where((t) => t.code.equals(code));
    return query.getSingleOrNull();
  }

  Future<Game?> getGameById(String id) async {
    final query = select(games)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> createGame({
    required String id,
    required String code,
    required String name,
    required int teamSize,
    required int boardSize,
    required DateTime createdAt,
  }) async {
    await into(games).insert(
      GamesCompanion(
        id: Value(id),
        code: Value(code),
        name: Value(name),
        teamSize: Value(teamSize),
        boardSize: Value(boardSize),
        createdAt: Value(createdAt.toIso8601String()),
      ),
    );
  }

  Future<void> deleteGame(String id) async {
    final teamsForGame = await (select(
      teams,
    )..where((t) => t.gameId.equals(id))).get();
    final teamIds = teamsForGame.map((t) => t.id).toList();

    final tilesForGame = await (select(
      bingoTiles,
    )..where((t) => t.gameId.equals(id))).get();
    final tileIds = tilesForGame.map((t) => t.id).toList();

    if (tileIds.isNotEmpty) {
      await (delete(teamBoardState)..where((t) => t.tileId.isIn(tileIds))).go();
    }

    if (teamIds.isNotEmpty) {
      await (delete(tileProofs)..where((t) => t.teamId.isIn(teamIds))).go();
    }

    if (tileIds.isNotEmpty) {
      await (delete(
        tileUniqueItems,
      )..where((t) => t.tileId.isIn(tileIds))).go();
    }

    await (delete(bingoTiles)..where((t) => t.gameId.equals(id))).go();

    if (teamIds.isNotEmpty) {
      await (delete(teamMembers)..where((t) => t.teamId.isIn(teamIds))).go();
    }

    await (delete(teams)..where((t) => t.gameId.equals(id))).go();

    await (update(users)..where((t) => t.gameId.equals(id))).write(
      const UsersCompanion(gameId: Value(null), teamId: Value(null)),
    );

    await (delete(games)..where((t) => t.id.equals(id))).go();
  }

  Future<void> createTeam({
    required String id,
    required String gameId,
    required String name,
    required String captainUserId,
  }) async {
    await into(teams).insert(
      TeamsCompanion.insert(
        id: id,
        gameId: gameId,
        name: name,
        captainUserId: captainUserId,
      ),
    );
  }

  Future<Team?> getTeamById(String id) async {
    final query = select(teams)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<List<Team>> getTeamsByGameId(String gameId) async {
    final query = select(teams)..where((t) => t.gameId.equals(gameId));
    return query.get();
  }

  Future<List<User>> getTeamMembers(String teamId) async {
    final query = select(users)..where((t) => t.teamId.equals(teamId));
    return query.get();
  }

  Future<List<User>> getUsersInGame(String gameId) async {
    final query = select(users)..where((t) => t.gameId.equals(gameId));
    return query.get();
  }

  Future<void> addUserToTeam({
    required String userId,
    required String teamId,
    required String gameId,
    bool isCaptain = false,
  }) async {
    // Check if user is admin first
    final user = await (select(
      users,
    )..where((t) => t.id.equals(userId))).getSingleOrNull();
    final isAdmin = user?.role == 'admin';

    // Preserve admin role, otherwise set captain or user
    final newRole = isAdmin ? 'admin' : (isCaptain ? 'captain' : 'user');

    await (update(users)..where((t) => t.id.equals(userId))).write(
      UsersCompanion(
        teamId: Value(teamId),
        gameId: Value(gameId),
        role: Value(newRole),
      ),
    );
  }

  Future<void> removeUserFromTeam(String userId) async {
    // Check if user is admin
    final user = await (select(
      users,
    )..where((t) => t.id.equals(userId))).getSingleOrNull();
    final newRole = user?.role == 'admin' ? 'admin' : 'user';

    await (update(users)..where((t) => t.id.equals(userId))).write(
      UsersCompanion(
        teamId: Value(null),
        gameId: Value(null),
        role: Value(newRole),
      ),
    );
  }

  Future<void> deleteTeam(String teamId) async {
    await (delete(teamBoardState)..where((t) => t.teamId.equals(teamId))).go();
    await (delete(tileProofs)..where((t) => t.teamId.equals(teamId))).go();
    await (delete(teamMembers)..where((t) => t.teamId.equals(teamId))).go();

    final members = await (select(
      users,
    )..where((t) => t.teamId.equals(teamId))).get();

    for (final member in members) {
      final newRole = member.role == 'admin' ? 'admin' : 'user';
      await (update(users)..where((t) => t.id.equals(member.id))).write(
        UsersCompanion(
          teamId: Value(null),
          gameId: Value(null),
          role: Value(newRole),
        ),
      );
    }

    await (delete(teams)..where((t) => t.id.equals(teamId))).go();
  }

  Future<void> createBoss({
    required String id,
    required String name,
    required String type,
    required String iconUrl,
    required DateTime createdAt,
  }) async {
    await into(bosses).insert(
      BossesCompanion(
        id: Value(id),
        name: Value(name),
        type: Value(type),
        iconUrl: Value(iconUrl),
        createdAt: Value(createdAt.toIso8601String()),
      ),
    );
  }

  Future<List<BossesData>> getAllBosses() async {
    final query = select(bosses)..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.get();
  }

  Future<BossesData?> getBossById(String id) async {
    final query = select(bosses)..where((t) => t.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<void> createBossUniqueItem({
    required String bossId,
    required String itemName,
  }) async {
    await into(bossUniqueItems).insert(
      BossUniqueItemsCompanion(
        bossId: Value(bossId),
        itemName: Value(itemName),
      ),
    );
  }

  Future<List<BossUniqueItem>> getUniqueItemsByBossId(String bossId) async {
    final query = select(bossUniqueItems)
      ..where((t) => t.bossId.equals(bossId))
      ..orderBy([(t) => OrderingTerm.asc(t.itemName)]);
    return query.get();
  }

  Future<void> createBingoTile({
    required String id,
    required String gameId,
    required String bossId,
    String? description,
    required int position,
    bool isAnyUnique = false,
    bool isOrLogic = false,
    int? anyNCount,
  }) async {
    await into(bingoTiles).insert(
      BingoTilesCompanion(
        id: Value(id),
        gameId: Value(gameId),
        bossId: Value(bossId),
        description: Value(description),
        position: Value(position),
        isAnyUnique: Value(isAnyUnique),
        isOrLogic: Value(isOrLogic),
        anyNCount: Value(anyNCount),
      ),
    );
  }

  Future<void> createTileUniqueItem({
    required String tileId,
    required String itemName,
    required int requiredCount,
  }) async {
    await into(tileUniqueItems).insert(
      TileUniqueItemsCompanion(
        tileId: Value(tileId),
        itemName: Value(itemName),
        requiredCount: Value(requiredCount),
      ),
    );
  }

  Future<List<TileUniqueItem>> getUniqueItemsByTileId(String tileId) async {
    final query = select(tileUniqueItems)
      ..where((t) => t.tileId.equals(tileId))
      ..orderBy([(t) => OrderingTerm.asc(t.itemName)]);
    return query.get();
  }

  Future<List<TileUniqueItem>> getUniqueItemsByTileIds(
    List<String> tileIds,
  ) async {
    if (tileIds.isEmpty) return [];
    final query = select(tileUniqueItems)
      ..where((t) => t.tileId.isIn(tileIds))
      ..orderBy([
        (t) => OrderingTerm.asc(t.tileId),
        (t) => OrderingTerm.asc(t.itemName),
      ]);
    return query.get();
  }

  Future<void> seedBosses() async {
    try {
      if (bossesJson.isEmpty || bossesJson == '[]') {
        developer.log(
          'Bosses JSON is empty or not found. Skipping seed.',
          name: 'database',
        );
        return;
      }
      final bossesList = jsonDecode(bossesJson) as List<dynamic>;
      final bosses = bossesList
          .map((json) => BossData.fromJson(json as Map<String, dynamic>))
          .toList();
      const uuid = Uuid();

      final existingBosses = await getAllBosses();
      final existingBossMap = {
        for (final boss in existingBosses) boss.name.toLowerCase(): boss,
      };

      var createdCount = 0;
      var skippedCount = 0;

      for (final bossData in bosses) {
        final existingBoss = existingBossMap[bossData.name.toLowerCase()];

        String bossId;
        if (existingBoss != null) {
          bossId = existingBoss.id;
          skippedCount++;
        } else {
          bossId = uuid.v4();
          await createBoss(
            id: bossId,
            name: bossData.name,
            type: bossData.type.value,
            iconUrl: bossData.icon,
            createdAt: DateTime.now(),
          );
          createdCount++;
        }

        final existingItems = await getUniqueItemsByBossId(bossId);
        final existingItemNames = existingItems
            .map((item) => item.itemName)
            .toSet();

        for (final itemName in bossData.uniques) {
          if (!existingItemNames.contains(itemName)) {
            await createBossUniqueItem(
              bossId: bossId,
              itemName: itemName,
            );
          }
        }
      }

      developer.log(
        'Boss seeding complete: $createdCount created, $skippedCount already existed',
        name: 'database',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to seed bosses',
        name: 'database',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<BingoTile>> getTilesByGameId(String gameId) async {
    final query = select(bingoTiles)..where((t) => t.gameId.equals(gameId));
    return query.get();
  }

  Future<User?> getUserById(String userId) async {
    final query = select(users)..where((t) => t.id.equals(userId));
    return query.getSingleOrNull();
  }

  Future<List<User>> getAllUsers() async {
    final query = select(users)..orderBy([(t) => OrderingTerm.asc(t.username)]);
    return query.get();
  }

  Future<void> deleteUser(String userId) async {
    await (delete(users)..where((t) => t.id.equals(userId))).go();
  }

  Future<void> setTeamBoardState({
    required String teamId,
    required String tileId,
    required String status,
    String? completedByUserId,
    DateTime? completedAt,
  }) async {
    await into(teamBoardState).insert(
      TeamBoardStateCompanion(
        teamId: Value(teamId),
        tileId: Value(tileId),
        status: Value(status),
        completedByUserId: Value(completedByUserId),
        completedAt: Value(completedAt?.toIso8601String()),
      ),
      mode: InsertMode.replace,
    );
  }

  Future<String?> getTeamBoardState({
    required String teamId,
    required String tileId,
  }) async {
    final query = select(teamBoardState)
      ..where((t) => t.teamId.equals(teamId))
      ..where((t) => t.tileId.equals(tileId));
    final result = await query.getSingleOrNull();
    return result?.status;
  }

  Future<Map<String, String>> getTeamBoardStates(String teamId) async {
    final query = select(teamBoardState)..where((t) => t.teamId.equals(teamId));
    final results = await query.get();
    return {for (final result in results) result.tileId: result.status};
  }

  Future<TeamBoardStateData?> getTeamBoardStateData({
    required String teamId,
    required String tileId,
  }) async {
    final query = select(teamBoardState)
      ..where((t) => t.teamId.equals(teamId))
      ..where((t) => t.tileId.equals(tileId));
    return query.getSingleOrNull();
  }

  Future<void> createTileProof({
    required String id,
    required String teamId,
    required String tileId,
    required String imageUrl,
    required String uploadedByUserId,
    required DateTime uploadedAt,
  }) async {
    await into(tileProofs).insert(
      TileProofsCompanion.insert(
        id: id,
        teamId: teamId,
        tileId: tileId,
        imageUrl: imageUrl,
        uploadedByUserId: uploadedByUserId,
        uploadedAt: uploadedAt.toIso8601String(),
      ),
    );
  }

  Future<List<TileProof>> getProofsByTileAndTeam({
    required String tileId,
    required String teamId,
  }) async {
    final query = select(tileProofs)
      ..where((t) => t.tileId.equals(tileId))
      ..where((t) => t.teamId.equals(teamId))
      ..orderBy([(t) => OrderingTerm.desc(t.uploadedAt)]);
    return query.get();
  }

  Future<List<TileProof>> getProofsByTeam(String teamId) async {
    final query = select(tileProofs)
      ..where((t) => t.teamId.equals(teamId))
      ..orderBy([(t) => OrderingTerm.desc(t.uploadedAt)]);
    return query.get();
  }

  Future<List<TileProof>> getProofsByGame(String gameId) async {
    final teamsList = await getTeamsByGameId(gameId);
    if (teamsList.isEmpty) return [];
    final teamIds = teamsList.map((t) => t.id).toList();
    final query = select(tileProofs)
      ..where((t) => t.teamId.isIn(teamIds))
      ..orderBy([(t) => OrderingTerm.desc(t.uploadedAt)]);
    return query.get();
  }

  Future<int> getProofCountByTileAndTeam({
    required String tileId,
    required String teamId,
  }) async {
    final query = select(tileProofs)
      ..where((t) => t.tileId.equals(tileId))
      ..where((t) => t.teamId.equals(teamId));
    final results = await query.get();
    return results.length;
  }

  Future<void> deleteTileProof(String id) async {
    await (delete(tileProofs)..where((t) => t.id.equals(id))).go();
  }

  Future<List<TeamBoardStateData>> getCompletedTilesByGame(
    String gameId,
  ) async {
    final teamsList = await getTeamsByGameId(gameId);
    if (teamsList.isEmpty) return [];
    final teamIds = teamsList.map((t) => t.id).toList();
    final query = select(teamBoardState)
      ..where((t) => t.teamId.isIn(teamIds))
      ..where((t) => t.status.equals('completed'))
      ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]);
    return query.get();
  }

  Future<Map<String, int>> getProofCountsByUser(String gameId) async {
    final proofs = await getProofsByGame(gameId);
    final counts = <String, int>{};
    for (final proof in proofs) {
      counts[proof.uploadedByUserId] =
          (counts[proof.uploadedByUserId] ?? 0) + 1;
    }
    return counts;
  }

  Future<Map<String, int>> getCompletionCountsByUser(String gameId) async {
    final completions = await getCompletedTilesByGame(gameId);
    final counts = <String, int>{};
    for (final completion in completions) {
      if (completion.completedByUserId != null) {
        counts[completion.completedByUserId!] =
            (counts[completion.completedByUserId!] ?? 0) + 1;
      }
    }
    return counts;
  }
}
