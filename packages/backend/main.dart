import 'dart:developer' as developer;
import 'dart:io';

import 'package:backend/config.dart';
import 'package:backend/database.dart';
import 'package:backend/db.dart';
import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  Config.init();

  final db = Db.instance;

  final dbHandler = handler.use(provider<AppDatabase>((_) => db));

  final server = await serve(dbHandler, ip, port);

  db.seedBosses().catchError((Object error, StackTrace stackTrace) {
    developer.log(
      'Boss seeding failed',
      name: 'main',
      error: error,
      stackTrace: stackTrace,
    );
  });

  return server;
}
