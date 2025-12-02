import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/user_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getGameUsers(context, id),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getGameUsers(RequestContext context, String id) async {
  try {
    final userService = context.read<UserService>();
    final users = await userService.getUsersInGame(id);

    return ResponseHelper.success(
      data: users.map((u) => u.toJson()).toList(),
    );
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
