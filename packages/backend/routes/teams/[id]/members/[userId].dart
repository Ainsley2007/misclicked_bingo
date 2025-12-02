import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/teams_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(
  RequestContext context,
  String id,
  String userId,
) async {
  return switch (context.request.method) {
    HttpMethod.delete => _removeTeamMember(context, id, userId),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _removeTeamMember(
  RequestContext context,
  String id,
  String userId,
) async {
  try {
    final currentUserId = context.read<String>();
    final teamsService = context.read<TeamsService>();

    final team = await teamsService.getTeamById(id);
    if (team == null) {
      return ResponseHelper.notFound(message: 'Team not found');
    }

    final isCaptain = await teamsService.isTeamCaptain(
      teamId: id,
      userId: currentUserId,
    );
    if (!isCaptain) {
      return ResponseHelper.forbidden(
        message: 'Only team captain can remove members',
      );
    }

    if (userId == currentUserId) {
      return ResponseHelper.validationError(
        message: 'Captain cannot remove themselves',
      );
    }

    await teamsService.removeMemberFromTeam(userId: userId);

    return ResponseHelper.noContent();
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
