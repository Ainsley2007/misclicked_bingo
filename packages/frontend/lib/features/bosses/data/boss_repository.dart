import 'package:dio/dio.dart';
import 'package:shared_models/shared_models.dart';

class BossRepository {
  BossRepository(this._dio);

  final Dio _dio;

  Future<List<Boss>> getAllBosses() async {
    final response = await _dio.get<List<dynamic>>('/bosses');
    return (response.data ?? [])
        .map((json) => Boss.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

