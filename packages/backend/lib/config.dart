import 'dart:io';
import 'package:dotenv/dotenv.dart';

class Config {
  static late DotEnv _env;
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _env = DotEnv();

    try {
      _env.load();
    } catch (e) {
      // Silently fall back to Platform.environment
    }

    _initialized = true;
  }

  static String get(String key, {String? defaultValue}) {
    if (!_initialized) init();
    return _env[key] ?? Platform.environment[key] ?? defaultValue ?? '';
  }

  static String get discordClientId => get('DISCORD_CLIENT_ID');
  static String get discordClientSecret => get('DISCORD_CLIENT_SECRET');
  static String get discordRedirectUri => get('DISCORD_REDIRECT_URI');
  static String get jwtSecret => get('JWT_SECRET');
  static String get dbPath => get('DB_PATH', defaultValue: 'darling-statue.db');
  static String get frontendOrigin =>
      get('FRONTEND_ORIGIN', defaultValue: 'http://localhost:3000');
  static String get cookieDomain =>
      get('COOKIE_DOMAIN', defaultValue: 'localhost');
}
