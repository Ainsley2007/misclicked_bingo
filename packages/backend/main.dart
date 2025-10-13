import 'dart:io';

import 'package:backend/database.dart';
import 'package:dart_frog/dart_frog.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  final db = AppDatabase();
  
  final dbHandler = handler.use(provider<AppDatabase>((_) => db));
  
  return serve(dbHandler, ip, port);
}
