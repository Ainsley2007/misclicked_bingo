import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/teams_service.dart';
import 'package:backend/services/user_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getTeamMembers(context, id),
    HttpMethod.post => _addTeamMember(context, id),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getTeamMembers(RequestContext context, String id) async {
  try {
    final teamsService = context.read<TeamsService>();
    final members = await teamsService.getTeamMembers(id);

    return ResponseHelper.success(
      data: members.map((u) => u.toJson()).toList(),
    );
  } catch (e) {
    return ResponseHelper.internalError();
  }
}

Future<Response> _addTeamMember(RequestContext context, String id) async {
  try {
    final currentUserId = context.read<String>();
    final teamsService = context.read<TeamsService>();
    final userService = context.read<UserService>();
    final body = await context.request.json() as Map<String, dynamic>;
    final userIdToAdd = body['userId'] as String?;

    if (userIdToAdd == null) {
      return ResponseHelper.validationError(message: 'userId is required');
    }

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
        message: 'Only team captain can add members',
      );
    }

    final userToAdd = await userService.getUserById(userIdToAdd);
    if (userToAdd == null) {
      return ResponseHelper.notFound(message: 'User not found');
    }

    if (userToAdd.teamId != null) {
      return ResponseHelper.error(
        message: 'User is already in a team',
        code: ErrorCode.alreadyInTeam,
      );
    }
    
    await teamsService.addMemberToTeam(
      userId: userIdToAdd,
      teamId: id,
      gameId: team.gameId,
    );

    return ResponseHelper.success(
      data: {'message': 'Member added successfully'},
    );
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
