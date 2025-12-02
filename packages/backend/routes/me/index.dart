import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/user_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    final payload = context.read<Map<String, dynamic>>();
    final userId = payload['sub'] as String?;

    if (userId == null) {
      return ResponseHelper.unauthorized();
    }

    final userService = context.read<UserService>();
    final user = await userService.getUserById(userId);

    if (user == null) {
      return ResponseHelper.notFound(message: 'User not found');
    }

    return ResponseHelper.success(data: user.toJson());
  } catch (e) {
    return ResponseHelper.unauthorized();
  }
}
