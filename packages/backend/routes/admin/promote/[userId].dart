import 'package:backend/database.dart';
import 'package:backend/db.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String userId) async {
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Method not allowed'},
    );
  }

  try {
    final db = Db.instance;

    final user = await (db.select(
      db.users,
    )..where((u) => u.id.equals(userId))).getSingleOrNull();

    if (user == null) {
      return Response.json(
        statusCode: 404,
        body: {'error': 'User not found'},
      );
    }

    await (db.update(
      db.users,
    )..where((u) => u.id.equals(userId))).write(
      const UsersCompanion(
        role: Value('admin'),
      ),
    );

    return Response.json(
      body: {
        'message': 'User promoted to admin',
        'userId': userId,
        'username': user.username,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Failed to promote user: $e'},
    );
  }
}

