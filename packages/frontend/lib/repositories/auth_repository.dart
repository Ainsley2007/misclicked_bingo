import 'package:dio/dio.dart';
import 'package:frontend/api/auth_api.dart';
import 'package:frontend/core/api/api_client.dart';

class AuthRepository {
  AuthRepository(this._api, this._baseUrl);

  final AuthApi _api;
  final String _baseUrl;

  String getLoginUrl() => '$_baseUrl/auth/discord/login';

  Future<void> logout() async {
    try {
      await _api.logout();
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }
}
