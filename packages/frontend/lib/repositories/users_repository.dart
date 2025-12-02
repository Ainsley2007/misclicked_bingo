import 'package:dio/dio.dart';
import 'package:frontend/api/users_api.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:shared_models/shared_models.dart';

class UsersRepository {
  UsersRepository(this._api);

  final UsersApi _api;

  Future<AppUser> getCurrentUser() async {
    try {
      return await _api.getCurrentUser();
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<List<AppUser>> getUsers() async {
    try {
      return await _api.getUsers();
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _api.deleteUser(userId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }
}
