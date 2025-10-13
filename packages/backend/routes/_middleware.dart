import 'package:backend/config.dart';
import 'package:backend/helpers/jwt.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(_corsMiddleware())
      .use(_authMiddleware());
}

Middleware _corsMiddleware() {
  return (handler) {
    return (context) async {
      final frontendOrigin = Config.frontendOrigin;

      if (context.request.method == HttpMethod.options) {
        return Response(
          statusCode: 204,
          headers: {
            'Access-Control-Allow-Origin': frontendOrigin,
            'Access-Control-Allow-Methods':
                'GET, POST, PUT, DELETE, PATCH, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'Access-Control-Allow-Credentials': 'true',
            'Access-Control-Max-Age': '86400',
          },
        );
      }

      final response = await handler(context);

      return response.copyWith(
        headers: {
          ...response.headers,
          'Access-Control-Allow-Origin': frontendOrigin,
          'Access-Control-Allow-Credentials': 'true',
        },
      );
    };
  };
}

Middleware _authMiddleware() {
  return (handler) {
    return (context) async {
      final cookies = context.request.headers['cookie'];
      if (cookies != null) {
        final authToken = _extractCookie(cookies, 'auth_token');
        if (authToken != null) {
          final payload = JwtHelper.verify(authToken);
          if (payload != null) {
            return handler(
              context.provide<Map<String, dynamic>>(() => payload),
            );
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
