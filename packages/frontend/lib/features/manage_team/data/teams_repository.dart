import 'package:dio/dio.dart';
import 'package:shared_models/shared_models.dart';

class TeamsRepository {
  TeamsRepository(this._dio);

  final Dio _dio;

  Future<Team> getTeam(String teamId) async {
    final response = await _dio.get<Map<String, dynamic>>('/teams/$teamId/info');
    return Team.fromJson(response.data!);
  }

  Future<List<AppUser>> getTeamMembers(String teamId) async {
    final response = await _dio.get<List<dynamic>>('/teams/$teamId/members');
    return response.data!
        .map((json) => AppUser.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addMember({
    required String teamId,
    required String userId,
  }) async {
    await _dio.post<void>('/teams/$teamId/members', data: {'userId': userId});
  }

  Future<void> removeMember({
    required String teamId,
    required String userId,
  }) async {
    await _dio.delete<void>('/teams/$teamId/members/$userId');
  }

  Future<void> disbandTeam(String teamId) async {
    await _dio.delete<void>('/teams/$teamId');
  }

  Future<Team> updateTeamColor({
    required String teamId,
    required String color,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/teams/$teamId',
      data: {'color': color},
    );
    return Team.fromJson(response.data!);
  }
}
