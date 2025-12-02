import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/game_service.dart';
import 'package:backend/services/teams_service.dart';
import 'package:backend/validators/auth_validator.dart';
import 'package:backend/validators/team_validator.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String code) async {
  return switch (context.request.method) {
    HttpMethod.post => _joinGame(context, code),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _joinGame(RequestContext context, String code) async {
  try {
    final userId = context.read<String>();
    final body = await context.request.json() as Map<String, dynamic>;
    final teamName = body['teamName'] as String?;

    final codeValidation = AuthValidator.validateGameCode(code: code);
    if (!codeValidation.isValid) {
      return ResponseHelper.error(
        message: codeValidation.errorMessage!,
        code: codeValidation.errorCode!,
      );
    }

    final nameValidation = TeamValidator.validateTeamName(name: teamName);
    if (!nameValidation.isValid) {
      return ResponseHelper.error(
        message: nameValidation.errorMessage!,
        code: nameValidation.errorCode!,
      );
    }

    final gameService = context.read<GameService>();
    final game = await gameService.getGameByCode(code);
    if (game == null) {
      return ResponseHelper.notFound(message: 'Game not found');
    }

    final teamsService = context.read<TeamsService>();
    final team = await teamsService.joinGameAndCreateTeam(
      gameId: game.id,
      teamName: teamName!,
      captainUserId: userId,
    );

    if (team == null) {
      return ResponseHelper.internalError(message: 'Failed to create team');
    }

    return ResponseHelper.success(
      data: {
        'game': game.toJson(),
        'team': team.toJson(),
      },
    );
  } catch (e) {
    return ResponseHelper.internalError();
  }
}
