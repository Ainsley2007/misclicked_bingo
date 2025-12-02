import 'dart:convert';

import 'package:backend/database.dart';
import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/teams_service.dart';
import 'package:backend/validators/team_validator.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.patch => _updateTeam(context, id),
    HttpMethod.delete => _disbandTeam(context, id),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _updateTeam(RequestContext context, String id) async {
  try {
    final currentUserId = context.read<String>();
    final db = context.read<AppDatabase>();
    final teamsService = TeamsService(db);

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
        message: 'Only team captain can update the team',
      );
    }

    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    if (data.containsKey('color')) {
      final color = data['color'] as String;
      final validation = TeamValidator.validateTeamColor(color: color);
      if (!validation.isValid) {
        return ResponseHelper.error(
          message: validation.errorMessage!,
          code: validation.errorCode!,
          details: validation.details,
        );
      }

      await teamsService.updateTeamColor(teamId: id, color: color);
    }

    final updatedTeam = await teamsService.getTeamById(id);
    return ResponseHelper.success(data: updatedTeam);
  } catch (e) {
    return ResponseHelper.internalError();
  }
}

Future<Response> _disbandTeam(RequestContext context, String id) async {
  try {
    final currentUserId = context.read<String>();
    final db = context.read<AppDatabase>();
    final teamsService = TeamsService(db);

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
        message: 'Only team captain can disband the team',
      );
    }

    await teamsService.disbandTeam(id);
    return ResponseHelper.noContent();
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
