import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final clientId = Platform.environment['DISCORD_CLIENT_ID'];
  final redirectUri = Platform.environment['DISCORD_REDIRECT_URI'];

  if (clientId == null || redirectUri == null) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'Discord OAuth not configured'},
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
