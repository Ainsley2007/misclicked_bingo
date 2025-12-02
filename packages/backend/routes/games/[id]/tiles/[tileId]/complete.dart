import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/game_service.dart';
import 'package:backend/services/tiles_service.dart';
import 'package:backend/services/user_service.dart';
import 'package:backend/validators/game_validator.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(
  RequestContext context,
  String gameId,
  String tileId,
) async {
  return switch (context.request.method) {
    HttpMethod.put => _toggleTileCompletion(context, gameId, tileId),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _toggleTileCompletion(
  RequestContext context,
  String gameId,
  String tileId,
) async {
  try {
    final userId = context.read<String>();
    final tilesService = context.read<TilesService>();
    final userService = context.read<UserService>();
    final gameService = context.read<GameService>();

    final user = await userService.getUserById(userId);
    if (user == null || user.teamId == null) {
      return ResponseHelper.forbidden(
        message: 'User must be part of a team',
      );
    }

    final game = await gameService.getGameById(gameId);
    if (game == null) {
      return ResponseHelper.notFound(message: 'Game not found');
    }

    final nowUtc = DateTime.now().toUtc();
    final startTime = game.startTime;
    final endTime = game.endTime;

    final timingValidation = GameValidator.validateGameTiming(
      now: nowUtc,
      startTime: startTime,
      endTime: endTime,
    );

    if (!timingValidation.isValid) {
      return ResponseHelper.error(
        message: timingValidation.errorMessage!,
        code: timingValidation.errorCode!,
        details: timingValidation.details,
      );
    }

    final result = await tilesService.toggleTileCompletion(
      tileId: tileId,
      teamId: user.teamId!,
      userId: userId,
    );

    if (!result.success) {
      return ResponseHelper.validationError(
        message: result.error,
      );
    }

    return ResponseHelper.success(data: {'status': result.status});
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
