import 'package:backend/helpers/jwt.dart';
import 'package:dart_frog/dart_frog.dart';

Middleware authMiddleware() {
  return (handler) {
    return (context) async {
      final cookies = context.request.headers['cookie'];
      if (cookies != null) {
        final authToken = _extractCookie(cookies, 'auth_token');
        if (authToken != null) {
          final payload = JwtHelper.verify(authToken);
          if (payload != null) {
            final userId = payload['sub'] as String?;
            if (userId != null) {
              return handler(
                context
                    .provide<Map<String, dynamic>>(() => payload)
                    .provide<String>(() => userId),
              );
            }
          }
        }
      }
      return handler(context);
    };
  };
}

String? _extractCookie(String cookies, String name) {
  final cookieList = cookies.split(';');
  for (final cookie in cookieList) {
    final parts = cookie.trim().split('=');
    if (parts.length == 2 && parts[0] == name) {
      return parts[1];
    }
  }
  return null;
}
