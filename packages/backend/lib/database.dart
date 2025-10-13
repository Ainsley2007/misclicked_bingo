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
  int get schemaVersion => 1;

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
  );
}
