import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/tiles_service.dart';
import 'package:backend/services/user_service.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:shared_models/shared_models.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
  String tileId,
) async {
  return switch (context.request.method) {
    HttpMethod.get => _getPublicProofs(context, id, tileId),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getPublicProofs(
  RequestContext context,
  String gameId,
  String tileId,
) async {
  try {
    final tilesService = context.read<TilesService>();
    final userService = context.read<UserService>();

    final teamIdParam = context.request.uri.queryParameters['teamId'];
    if (teamIdParam == null) {
      return ResponseHelper.validationError(
        message: 'teamId query parameter is required',
      );
    }

    final proofs = await tilesService.getProofsByTileAndTeam(
      tileId: tileId,
      teamId: teamIdParam,
    );

    final userIds = proofs.map((p) => p.uploadedByUserId).toSet();
    final users = <String, AppUser>{};
    for (final userId in userIds) {
      final user = await userService.getUserById(userId);
      if (user != null) users[userId] = user;
    }

    final result = proofs.map((p) {
      final user = users[p.uploadedByUserId];
      return TileProof(
        id: p.id,
        teamId: p.teamId,
        tileId: p.tileId,
        imageUrl: p.imageUrl,
        uploadedByUserId: p.uploadedByUserId,
        uploadedByUsername: user?.globalName ?? user?.username,
        uploadedAt: DateTime.parse(p.uploadedAt),
      ).toJson();
    }).toList();

    return ResponseHelper.success(data: result);
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
