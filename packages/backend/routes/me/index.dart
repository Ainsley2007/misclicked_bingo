import 'package:backend/db.dart';
import 'package:backend/helpers/response_helper.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    final payload = context.read<Map<String, dynamic>>();
    final userId = payload['sub'] as String?;

    if (userId == null) {
      return ResponseHelper.unauthorized();
    }

    final db = Db.instance;
    final user = await (db.select(db.users)
          ..where((u) => u.id.equals(userId)))
        .getSingleOrNull();

    if (user == null) {
      return ResponseHelper.notFound(message: 'User not found');
    }

    return ResponseHelper.success(
      data: {
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
    return ResponseHelper.unauthorized();
  }
}
