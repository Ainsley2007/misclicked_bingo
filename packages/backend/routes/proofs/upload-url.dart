import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/proofs_service.dart';
import 'package:backend/services/user_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _getUploadUrl(context),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getUploadUrl(RequestContext context) async {
  try {
    final userId = context.read<String>();
    final proofsService = context.read<ProofsService>();
    final userService = context.read<UserService>();

    final user = await userService.getUserById(userId);
    if (user == null || user.teamId == null) {
      return ResponseHelper.forbidden(
        message: 'User must be part of a team',
      );
    }

    final body = await context.request.json() as Map<String, dynamic>;
    final gameId = body['gameId'] as String?;
    final fileName = body['fileName'] as String?;

    if (gameId == null || fileName == null) {
      return ResponseHelper.validationError(
        message: 'Missing required fields: gameId, fileName',
      );
    }

    final result = await proofsService.getPresignedUploadUrl(
      gameId: gameId,
      teamId: user.teamId!,
      fileName: fileName,
    );

    return ResponseHelper.success(data: result);
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
