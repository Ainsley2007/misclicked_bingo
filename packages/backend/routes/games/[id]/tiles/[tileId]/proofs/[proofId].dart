import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/proofs_service.dart';
import 'package:backend/services/tiles_service.dart';
import 'package:backend/services/user_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
  String tileId,
  String proofId,
) async {
  return switch (context.request.method) {
    HttpMethod.delete => _deleteProof(context, id, tileId, proofId),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _deleteProof(
  RequestContext context,
  String gameId,
  String tileId,
  String proofId,
) async {
  try {
    final userId = context.read<String>();
    final proofsService = context.read<ProofsService>();
    final userService = context.read<UserService>();
    final tilesService = context.read<TilesService>();

    final user = await userService.getUserById(userId);
    if (user == null || user.teamId == null) {
      return ResponseHelper.forbidden(message: 'User must be part of a team');
    }

    final tileStatus = await tilesService.getTeamBoardState(
      teamId: user.teamId!,
      tileId: tileId,
    );
    if (tileStatus == 'completed') {
      return ResponseHelper.forbidden(
        message: 'Cannot delete proof from completed tile',
      );
    }

    await proofsService.deleteProof(proofId);

    return ResponseHelper.noContent();
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
