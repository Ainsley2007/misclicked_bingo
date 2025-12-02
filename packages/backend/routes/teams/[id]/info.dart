import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/teams_service.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return switch (context.request.method) {
    HttpMethod.get => _getTeam(context, id),
    _ => ResponseHelper.methodNotAllowed(),
  };
}

Future<Response> _getTeam(RequestContext context, String id) async {
  try {
    final teamsService = context.read<TeamsService>();
    final team = await teamsService.getTeamById(id);

    if (team == null) {
      return ResponseHelper.notFound(message: 'Team not found');
    }

    return ResponseHelper.success(data: team.toJson());
  } catch (e) {
    return ResponseHelper.internalError();
  }
}

