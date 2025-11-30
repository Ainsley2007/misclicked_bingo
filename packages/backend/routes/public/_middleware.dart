import 'package:backend/config.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(_corsMiddleware());
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
            'Access-Control-Allow-Methods': 'GET, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type',
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

