import 'package:dart_frog/dart_frog.dart';

Middleware corsHeaders() {
  return (handler) {
    return (context) async {
      final origin = context.request.headers['origin'] ?? '';

      if (context.request.method == HttpMethod.options) {
        return Response(
          statusCode: 204,
          headers: _corsHeaders(origin),
        );
      }

      final response = await handler(context);

      return response.copyWith(
        headers: {
          ...response.headers,
          ..._corsHeaders(origin),
        },
      );
    };
  };
}

Map<String, String> _corsHeaders(String origin) {
  const allowedOrigins = [
    'https://osrs-bingo-fe.globeapp.dev',
    'http://localhost:3000',
    'http://localhost:8080',
  ];

  final allowOrigin = allowedOrigins.contains(origin)
      ? origin
      : allowedOrigins.first;

  return {
    'Access-Control-Allow-Origin': allowOrigin,
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS, PATCH',
    'Access-Control-Allow-Headers':
        'Origin, Content-Type, Accept, Authorization, Cookie',
    'Access-Control-Allow-Credentials': 'true',
    'Access-Control-Max-Age': '86400',
  };
}
