import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shared_models/shared_models.dart';

part 'bosses_api.g.dart';

@RestApi()
abstract class BossesApi {
  factory BossesApi(Dio dio, {String? baseUrl}) = _BossesApi;

  @GET('/bosses')
  Future<List<Boss>> getBosses();
}
