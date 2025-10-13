import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.delete => _deleteGame(context, id),
    _ => Response(statusCode: HttpStatus.methodNotAllowed),
  };
}

Future<Response> _deleteGame(RequestContext context, String id) async {
  try {
    final db = context.read<AppDatabase>();
    await db.deleteGame(id);
    
    return Response(statusCode: HttpStatus.noContent);
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to delete game'},
    );
  }
}

