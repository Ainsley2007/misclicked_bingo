import 'package:backend/helpers/cookies.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final response = Response.json(body: {'message': 'Logged out successfully'});
  return CookieHelper.clearAuthCookie(response);
}
