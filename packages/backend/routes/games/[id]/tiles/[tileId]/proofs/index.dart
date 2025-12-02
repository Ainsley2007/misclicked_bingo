import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/proofs_service.dart';
import 'package:backend/services/teams_service.dart';
import 'package:backend/services/tiles_service.dart';
import 'package:backend/services/user_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
  String tileId,
) async {
  return switch (context.request.method) {
    HttpMethod.get => _getProofs(context, tileId),
    HttpMethod.post => _createProof(context, tileId),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getProofs(RequestContext context, String tileId) async {
  try {
    final userId = context.read<String>();
    final proofsService = context.read<ProofsService>();
    final userService = context.read<UserService>();
    final teamsService = context.read<TeamsService>();

    final user = await userService.getUserById(userId);
    if (user == null || user.teamId == null) {
      return ResponseHelper.forbidden(message: 'User must be part of a team');
    }

    final teamIdParam = context.request.uri.queryParameters['teamId'];
    final teamId = teamIdParam ?? user.teamId!;

    final requestedTeam = await teamsService.getTeamById(teamId);
    if (requestedTeam == null || requestedTeam.gameId != user.gameId) {
      return ResponseHelper.forbidden(
        message: 'Team not found or not in same game',
      );
    }

    final proofs = await proofsService.getProofsForTile(
      tileId: tileId,
      teamId: teamId,
    );

    return ResponseHelper.success(
      data: proofs.map((p) => p.toJson()).toList(),
    );
  } catch (e) {
    return ResponseHelper.internalError();
  }
}

Future<Response> _createProof(RequestContext context, String tileId) async {
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
        message: 'Cannot add proof to completed tile',
      );
    }

    final body = await context.request.json() as Map<String, dynamic>;
    final imageUrl = body['imageUrl'] as String?;

    if (imageUrl == null) {
      return ResponseHelper.validationError(
        message: 'Missing required field: imageUrl',
      );
    }

    final existingProofs = await proofsService.getProofsForTile(
      tileId: tileId,
      teamId: user.teamId!,
    );

    if (existingProofs.length >= 10) {
      return ResponseHelper.validationError(
        message: 'Maximum of 10 proofs per tile',
      );
    }

    final proof = await proofsService.createProof(
      teamId: user.teamId!,
      tileId: tileId,
      imageUrl: imageUrl,
      uploadedByUserId: userId,
    );

    return ResponseHelper.created(data: proof.toJson());
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
