import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/user_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String userId) async {
  if (context.request.method != HttpMethod.post) {
    return ResponseHelper.methodNotAllowed();
  }

  try {
    final userService = context.read<UserService>();

    final user = await userService.getUserById(userId);
    if (user == null) {
      return ResponseHelper.notFound(message: 'User not found');
    }

    await userService.promoteToAdmin(userId);

    return ResponseHelper.success(
      data: {
        'message': 'User promoted to admin',
        'userId': userId,
        'username': user.username,
      },
    );
  } catch (e) {
    return ResponseHelper.internalError();
  }
}

