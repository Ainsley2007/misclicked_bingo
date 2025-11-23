import 'dart:io';
import 'package:backend/database.dart';
import 'package:backend/db.dart';
import 'package:drift/drift.dart';

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    print(
      'Usage: dart run scripts/update_boss_icon.dart <bossName> <newIconUrl>',
    );
    exit(1);
  }

  final bossName = args[0];
  final newIconUrl = args[1];
  final db = Db.instance;

  try {
    final bosses = await db.getAllBosses();
    final boss = bosses
        .where((b) => b.name.toLowerCase() == bossName.toLowerCase())
        .firstOrNull;

    if (boss == null) {
      print('Boss not found: $bossName');
      exit(1);
    }

    await (db.update(db.bosses)..where((b) => b.id.equals(boss.id))).write(
      BossesCompanion(iconUrl: Value(newIconUrl)),
    );

    print('Updated icon URL for "$bossName" to: $newIconUrl');
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
