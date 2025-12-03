import 'package:dio/dio.dart';
import 'package:frontend/api/teams_api.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:shared_models/shared_models.dart';

class TeamsRepository {
  TeamsRepository(this._api);

  final TeamsApi _api;

  Future<Team> updateTeamColor({
    required String teamId,
    required String color,
  }) async {
    try {
      return await _api.updateTeam(teamId, {'color': color});
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<void> disbandTeam(String teamId) async {
    try {
      await _api.deleteTeam(teamId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<List<AppUser>> getTeamMembers(String teamId) async {
    try {
      return await _api.getTeamMembers(teamId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<void> addMember({
    required String teamId,
    required String userId,
  }) async {
    try {
      await _api.addMember(teamId, {'userId': userId});
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }

  Future<void> removeMember({
    required String teamId,
    required String userId,
  }) async {
    try {
      await _api.removeMember(teamId, userId);
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }
}
