import 'package:backend/database.dart';
import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/tiles_service.dart';
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
    final db = context.read<AppDatabase>();
    final tilesService = context.read<TilesService>();

    final user = await db.getUserById(userId);
    if (user == null || user.teamId == null) {
      return ResponseHelper.forbidden(
        message: 'User must be part of a team',
      );
    }

    final game = await db.getGameById(gameId);
    if (game == null) {
      return ResponseHelper.notFound(message: 'Game not found');
    }

    final nowUtc = DateTime.now().toUtc();
    DateTime? startTime;
    DateTime? endTime;

    if (game.startTime != null) {
      startTime = DateTime.tryParse(game.startTime!);
    }
    if (game.endTime != null) {
      endTime = DateTime.tryParse(game.endTime!);
    }

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
