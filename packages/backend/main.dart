import 'dart:io';

import 'package:backend/config.dart';
import 'package:backend/database.dart';
import 'package:backend/db.dart';
import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  Config.init();

  final db = Db.instance;

  // Seed bosses on startup (idempotent - won't create duplicates)
  await db.seedBosses();

  final dbHandler = handler.use(provider<AppDatabase>((_) => db));

  return serve(dbHandler, ip, port);
}
