import 'dart:io';

import 'package:backend/config.dart';
import 'package:dart_frog/dart_frog.dart';

class CookieHelper {
  static Response setAuthCookie(Response response, String jwtToken) {
    final domain = Config.cookieDomain;
    final cookie = Cookie('auth_token', jwtToken)
      ..httpOnly = true
      ..secure = true
      ..sameSite = SameSite.lax
      ..path = '/'
      ..maxAge = 60 * 60 * 24 * 30;

    if (domain.isNotEmpty && domain != 'localhost') {
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
    final domain = Config.cookieDomain;
    final cookie = Cookie('auth_token', '')
      ..httpOnly = true
      ..secure = true
      ..sameSite = SameSite.lax
      ..path = '/'
      ..maxAge = 0;

    if (domain.isNotEmpty && domain != 'localhost') {
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
