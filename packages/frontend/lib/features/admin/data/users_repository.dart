import 'package:dio/dio.dart';
import 'package:shared_models/shared_models.dart';

class UsersRepository {
  const UsersRepository(this._dio);

  final Dio _dio;

  Future<List<AppUser>> getUsers() async {
    final response = await _dio.get<List<dynamic>>('/users');

    if (response.statusCode == 200 && response.data != null) {
      return response.data!
          .map((json) => AppUser.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  Future<void> deleteUser(String userId) async {
    final response = await _dio.delete<void>(
      '/users',
      data: {'userId': userId},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }
}
