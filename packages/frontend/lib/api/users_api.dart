import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shared_models/shared_models.dart';

part 'users_api.g.dart';

@RestApi()
abstract class UsersApi {
  factory UsersApi(Dio dio, {String? baseUrl}) = _UsersApi;

  @GET('/me')
  Future<AppUser> getCurrentUser();

  @GET('/users')
  Future<List<AppUser>> getUsers();

  @DELETE('/users/{id}')
  Future<void> deleteUser(@Path('id') String id);
}
