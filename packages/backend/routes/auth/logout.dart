import 'package:backend/helpers/cookies.dart';
import 'package:backend/helpers/response_helper.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  final response = ResponseHelper.success(
    data: {'message': 'Logged out successfully'},
  );
  return CookieHelper.clearAuthCookie(response);
}
