import 'dart:convert';
import 'dart:developer' as developer;
import 'package:backend/config.dart';
import 'package:backend/database.dart';
import 'package:backend/helpers/jwt.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class AuthService {
  AuthService(this._db);
  final AppDatabase _db;
  Future<String> exchangeCodeForToken(String code) async {
    final clientId = Config.discordClientId;
    final clientSecret = Config.discordClientSecret;
    final redirectUri = Config.discordRedirectUri;

    if (clientId.isEmpty || clientSecret.isEmpty || redirectUri.isEmpty) {
      developer.log(
        'Missing Discord OAuth environment variables',
        name: 'auth.discord',
        level: 1000,
        error:
            'clientId: ${clientId.isNotEmpty}, clientSecret: ${clientSecret.isNotEmpty}, redirectUri: ${redirectUri.isNotEmpty}',
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

  Future<Map<String, dynamic>> fetchDiscordUser(String accessToken) async {
    final response = await http.get(
      Uri.https('discord.com', '/api/users/@me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<String> upsertUser(Map<String, dynamic> discordUser) async {
    final discordId = discordUser['id'] as String;

    final existingUser = await (_db.select(
      _db.users,
    )..where((u) => u.discordId.equals(discordId))).getSingleOrNull();

    if (existingUser != null) {
      await (_db.update(
        _db.users,
      )..where((u) => u.id.equals(existingUser.id))).write(
        UsersCompanion(
          globalName: Value(discordUser['global_name'] as String?),
          username: Value(discordUser['username'] as String?),
          avatar: Value(discordUser['avatar'] as String?),
        ),
      );
      return existingUser.id;
    }

    final userId = const Uuid().v4();
    await _db
        .into(_db.users)
        .insert(
          UsersCompanion.insert(
            id: userId,
            discordId: discordId,
            globalName: Value(discordUser['global_name'] as String?),
            username: Value(discordUser['username'] as String?),
            avatar: Value(discordUser['avatar'] as String?),
            role: const Value('user'),
          ),
        );

    return userId;
  }

  String generateJwtToken({
    required String userId,
    required String discordId,
    String role = 'user',
  }) {
    return JwtHelper.sign({
      'sub': userId,
      'discordId': discordId,
      'role': role,
    });
  }
}
