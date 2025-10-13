import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:backend/database.dart';
import 'package:backend/db.dart';
import 'package:backend/helpers/cookies.dart';
import 'package:backend/helpers/jwt.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  final code = context.request.uri.queryParameters['code'];

  if (code == null) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Missing authorization code'},
    );
  }

  try {
    final accessToken = await _exchangeCodeForToken(code);
    final discordUser = await _fetchDiscordUser(accessToken);

    final userId = await _upsertUser(discordUser);

    final jwtToken = JwtHelper.sign({
      'sub': userId,
      'discordId': discordUser['id'],
      'role': 'user',
    });

    final frontendOrigin =
        Platform.environment['FRONTEND_ORIGIN'] ?? 'http://localhost:3000';

    final response = Response(
      statusCode: 302,
      headers: {'Location': frontendOrigin},
    );

    return CookieHelper.setAuthCookie(response, jwtToken);
  } catch (e, stackTrace) {
    developer.log(
      'Discord OAuth callback failed',
      name: 'auth.discord',
      level: 1000,
      error: e,
      stackTrace: stackTrace,
    );
    return Response.json(
      statusCode: 500,
      body: {'error': 'Authentication failed: $e'},
    );
  }
}

Future<String> _exchangeCodeForToken(String code) async {
  final clientId = Platform.environment['DISCORD_CLIENT_ID'];
  final clientSecret = Platform.environment['DISCORD_CLIENT_SECRET'];
  final redirectUri = Platform.environment['DISCORD_REDIRECT_URI'];

  if (clientId == null || clientSecret == null || redirectUri == null) {
    developer.log(
      'Missing Discord OAuth environment variables',
      name: 'auth.discord',
      level: 1000,
      error:
          'clientId: ${clientId != null}, clientSecret: ${clientSecret != null}, redirectUri: ${redirectUri != null}',
    );
    throw Exception('Discord OAuth not properly configured');
  }

  final response = await http.post(
    Uri.https('discord.com', '/api/oauth2/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'client_id': clientId,
      'client_secret': clientSecret,
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUri,
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Token exchange failed: ${response.body}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  return data['access_token'] as String;
}

Future<Map<String, dynamic>> _fetchDiscordUser(String accessToken) async {
  final response = await http.get(
    Uri.https('discord.com', '/api/users/@me'),
    headers: {'Authorization': 'Bearer $accessToken'},
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch user: ${response.body}');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}

Future<String> _upsertUser(Map<String, dynamic> discordUser) async {
  final db = Db.instance;
  final discordId = discordUser['id'] as String;

  final existingUser = await (db.select(
    db.users,
  )..where((u) => u.discordId.equals(discordId))).getSingleOrNull();

  if (existingUser != null) {
    await (db.update(
      db.users,
    )..where((u) => u.id.equals(existingUser.id))).write(
      UsersCompanion(
        globalName: Value(discordUser['global_name'] as String?),
        username: Value(discordUser['username'] as String?),
        email: Value(discordUser['email'] as String?),
        avatar: Value(discordUser['avatar'] as String?),
      ),
    );
    return existingUser.id;
  }

  final userId = const Uuid().v4();
  await db
      .into(db.users)
      .insert(
        UsersCompanion.insert(
          id: userId,
          discordId: discordId,
          globalName: Value(discordUser['global_name'] as String?),
          username: Value(discordUser['username'] as String?),
          email: Value(discordUser['email'] as String?),
          avatar: Value(discordUser['avatar'] as String?),
          role: const Value('user'),
        ),
      );

  return userId;
}
