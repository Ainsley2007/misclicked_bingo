import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shared_models/shared_models.dart';

part 'teams_api.g.dart';

@RestApi()
abstract class TeamsApi {
  factory TeamsApi(Dio dio, {String? baseUrl}) = _TeamsApi;

  @PATCH('/teams/{id}')
  Future<Team> updateTeam(@Path('id') String id, @Body() Map<String, dynamic> body);

  @DELETE('/teams/{id}')
  Future<void> deleteTeam(@Path('id') String id);

  @GET('/teams/{id}/members')
  Future<List<AppUser>> getTeamMembers(@Path('id') String teamId);

  @POST('/teams/{id}/members/{userId}')
  Future<void> addMember(@Path('id') String teamId, @Path('userId') String userId);

  @DELETE('/teams/{id}/members/{userId}')
  Future<void> removeMember(@Path('id') String teamId, @Path('userId') String userId);
}
