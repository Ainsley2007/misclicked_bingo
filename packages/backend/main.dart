import 'dart:developer' as developer;
import 'dart:io';

import 'package:backend/config.dart';
import 'package:backend/database.dart';
import 'package:backend/db.dart';
import 'package:backend/services/activity_service.dart';
import 'package:backend/services/proofs_service.dart';
import 'package:backend/services/r2_service.dart';
import 'package:backend/services/tiles_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  Config.init();

  final db = Db.instance;
  final r2Service = R2Service();
  final proofsService = ProofsService(db, r2Service);
  final activityService = ActivityService(db);
  final tilesService = TilesService(db);

  final dbHandler = handler
      .use(provider<AppDatabase>((_) => db))
      .use(provider<R2Service>((_) => r2Service))
      .use(provider<ProofsService>((_) => proofsService))
      .use(provider<ActivityService>((_) => activityService))
      .use(provider<TilesService>((_) => tilesService));

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
