import 'dart:developer' as developer;
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtHelper {
  static String get _secret {
    final secret = Platform.environment['JWT_SECRET'];
    if (secret == null || secret.isEmpty) {
      throw Exception('JWT_SECRET environment variable not set');
    }
    return secret;
  }

  static String sign(Map<String, dynamic> payload) {
    final jwt = JWT(
      {
        ...payload,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp':
            DateTime.now()
                .add(const Duration(days: 30))
                .millisecondsSinceEpoch ~/
            1000,
      },
    );

    return jwt.sign(SecretKey(_secret));
  }

  static Map<String, dynamic>? verify(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secret));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException catch (e, stackTrace) {
      developer.log(
        'JWT expired',
        name: 'auth.jwt',
        level: 900,
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    } on JWTException catch (e, stackTrace) {
      developer.log(
        'JWT verification failed',
        name: 'auth.jwt',
        level: 1000,
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
