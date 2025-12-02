import 'dart:io';
import 'package:backend/database.dart';
import 'package:backend/db.dart';
import 'package:drift/drift.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: dart run scripts/promote_user.dart <userId|discordId>');
    exit(1);
  }

  final identifier = args[0];
  final db = Db.instance;

  try {
    var user = await (db.select(
      db.users,
    )..where((u) => u.id.equals(identifier))).getSingleOrNull();

    user ??= await (db.select(
        db.users,
      )..where((u) => u.discordId.equals(identifier))).getSingleOrNull();

    if (user == null) {
      print('User not found: $identifier');
      exit(1);
    }

    final userId = user.id;
    await (db.update(
      db.users,
    )..where((u) => u.id.equals(userId))).write(
      const UsersCompanion(
        role: Value('admin'),
      ),
    );

    print(
      'User ${user.username ?? user.globalName ?? user.id} promoted to admin',
    );
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
