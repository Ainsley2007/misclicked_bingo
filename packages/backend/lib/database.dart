import 'dart:io';

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
    final dbPath = Platform.environment['DB_PATH'] ?? 'darling-statue.db';
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

  Future<void> createGame({
    required String id,
    required String code,
    required String name,
    required DateTime createdAt,
  }) async {
    await into(games).insert(
      GamesCompanion.insert(
        id: id,
        code: code,
        name: name,
        createdAt: createdAt.toIso8601String(),
      ),
    );
  }

  Future<void> deleteGame(String id) async {
    await (delete(games)..where((t) => t.id.equals(id))).go();
  }
}
