import 'package:backend/config.dart';
import 'package:backend/helpers/response_helper.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final clientId = Config.discordClientId;
  final redirectUri = Config.discordRedirectUri;

  if (clientId.isEmpty || redirectUri.isEmpty) {
    return ResponseHelper.internalError(
      message: 'Discord OAuth not configured',
    );
  }

  final authUrl = Uri.https('discord.com', '/api/oauth2/authorize', {
    'client_id': clientId,
    'response_type': 'code',
    'scope': 'identify email',
    'redirect_uri': redirectUri,
    'prompt': 'none',
  });

  return Response(
    statusCode: 302,
    headers: {'Location': authUrl.toString()},
  );
}
