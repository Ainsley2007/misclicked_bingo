import 'package:dio/dio.dart';
import 'package:frontend/api/bosses_api.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:shared_models/shared_models.dart';

class BossesRepository {
  BossesRepository(this._api);

  final BossesApi _api;

  Future<List<Boss>> getBosses() async {
    try {
      return await _api.getBosses();
    } on DioException catch (e) {
      throw e.toApiException();
    }
  }
}
