import 'package:backend/config.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

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

@DriftDatabase(tables: [Users, Games, Teams, TeamMembers])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

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
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await customStatement('ALTER TABLE users ADD COLUMN avatar TEXT');
      }
    },
    beforeOpen: (details) async {
      await customStatement(
        'CREATE TABLE IF NOT EXISTS _migration_check (version INTEGER)',
      );

      if (details.wasCreated == false) {
        try {
          await customStatement('SELECT avatar FROM users LIMIT 1');
        } catch (e) {
          await customStatement('ALTER TABLE users ADD COLUMN avatar TEXT');
        }
      }
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
    required DateTime createdAt,
  }) async {
    await into(games).insert(
      GamesCompanion(
        id: Value(id),
        code: Value(code),
        name: Value(name),
        teamSize: Value(teamSize),
        createdAt: Value(createdAt.toIso8601String()),
      ),
    );
  }

  Future<void> deleteGame(String id) async {
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
    // Get all team members to preserve admin roles
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
}
