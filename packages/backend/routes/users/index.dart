import 'dart:developer' as developer;

import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/user_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _getUsers(context),
    HttpMethod.delete => _deleteUser(context),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getUsers(RequestContext context) async {
  try {
    final userService = context.read<UserService>();
    final users = await userService.getAllUsers();

    return ResponseHelper.success(data: users.map((u) => u.toJson()).toList());
  } catch (e) {
    return ResponseHelper.internalError();
  }
}

Future<Response> _deleteUser(RequestContext context) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final userId = body['userId'] as String?;

    if (userId == null || userId.trim().isEmpty) {
      return ResponseHelper.validationError(message: 'User ID is required');
    }

    final userService = context.read<UserService>();
    await userService.deleteUser(userId);

    return ResponseHelper.noContent();
  } catch (e, stackTrace) {
    developer.log(
      'Failed to delete user',
      name: 'users',
      error: e,
      stackTrace: stackTrace,
    );
    return ResponseHelper.internalError();
  }
}
