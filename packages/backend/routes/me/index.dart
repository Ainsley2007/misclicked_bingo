import 'package:backend/db.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    final payload = context.read<Map<String, dynamic>>();
    final userId = payload['sub'] as String?;

    if (userId == null) {
      return Response.json(
        statusCode: 401,
        body: {'error': 'Unauthorized'},
      );
    }

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

    return Response.json(
      body: {
        'id': user.id,
        'discordId': user.discordId,
        'globalName': user.globalName,
        'username': user.username,
        'email': user.email,
        'avatar': user.avatar,
        'role': user.role,
        'teamId': user.teamId,
        'gameId': user.gameId,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Unauthorized'},
    );
  }
}
