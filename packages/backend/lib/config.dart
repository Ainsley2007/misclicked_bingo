import 'dart:io';
import 'package:dotenv/dotenv.dart';

class Config {
  static DotEnv? _env;
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    // Only try to load .env file if it exists (local development)
    final envFile = File('.env');
    if (envFile.existsSync()) {
      try {
        _env = DotEnv()..load();
      } catch (e) {
        // Failed to load .env, will use Platform.environment
        _env = null;
      }
    }
  }

  static String get(String key, {String? defaultValue}) {
    if (!_initialized) init();
    // First try dotenv (if loaded), then Platform.environment, then default
    return _env?[key] ?? Platform.environment[key] ?? defaultValue ?? '';
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

  static String get r2AccountId => get('R2_ACCOUNT_ID');
  static String get r2AccessKeyId => get('R2_ACCESS_KEY_ID');
  static String get r2SecretAccessKey => get('R2_SECRET_ACCESS_KEY');
  static String get r2BucketName => get('R2_BUCKET_NAME');
  static String get r2PublicUrl => get('R2_PUBLIC_URL');
}
