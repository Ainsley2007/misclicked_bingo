import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

class CookieHelper {
  static Response setAuthCookie(Response response, String jwtToken) {
    final domain = Platform.environment['COOKIE_DOMAIN'];
    final cookie = Cookie('auth_token', jwtToken)
      ..httpOnly = true
      ..secure = true
      ..sameSite = SameSite.lax
      ..path = '/'
      ..maxAge = 60 * 60 * 24 * 30;

    if (domain != null && domain.isNotEmpty && domain != 'localhost') {
      cookie.domain = domain;
    }

    return response.copyWith(
      headers: {
        ...response.headers,
        'set-cookie': cookie.toString(),
      },
    );
  }

  static Response clearAuthCookie(Response response) {
    final domain = Platform.environment['COOKIE_DOMAIN'];
    final cookie = Cookie('auth_token', '')
      ..httpOnly = true
      ..secure = true
      ..sameSite = SameSite.lax
      ..path = '/'
      ..maxAge = 0;

    if (domain != null && domain.isNotEmpty && domain != 'localhost') {
      cookie.domain = domain;
    }

    return response.copyWith(
      headers: {
        ...response.headers,
        'set-cookie': cookie.toString(),
      },
    );
  }
}
