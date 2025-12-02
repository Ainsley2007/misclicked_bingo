import 'dart:developer' as developer;

import 'package:backend/config.dart';
import 'package:backend/helpers/cookies.dart';
import 'package:backend/helpers/response_helper.dart';
import 'package:backend/services/auth_service.dart';
import 'package:backend/validators/auth_validator.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final code = context.request.uri.queryParameters['code'];

  final validation = AuthValidator.validateAuthCode(code: code);
  if (!validation.isValid) {
    return ResponseHelper.error(
      message: validation.errorMessage!,
      code: validation.errorCode!,
      statusCode: 400,
    );
  }

  try {
    final authService = context.read<AuthService>();
    final accessToken = await authService.exchangeCodeForToken(code!);
    final discordUser = await authService.fetchDiscordUser(accessToken);
    final userId = await authService.upsertUser(discordUser);

    final jwtToken = authService.generateJwtToken(
      userId: userId,
      discordId: discordUser['id'] as String,
    );

    final frontendOrigin = Config.frontendOrigin;
    final response = Response(
      statusCode: 302,
      headers: {'Location': frontendOrigin},
    );

    return CookieHelper.setAuthCookie(response, jwtToken);
  } catch (e, stackTrace) {
    developer.log(
      'Discord OAuth callback failed',
      name: 'auth.discord',
      level: 1000,
      error: e,
      stackTrace: stackTrace,
    );
    return ResponseHelper.internalError(
      message: 'Authentication failed',
    );
  }
}
