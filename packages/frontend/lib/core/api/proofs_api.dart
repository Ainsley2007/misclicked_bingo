import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:shared_models/shared_models.dart';

part 'proofs_api.g.dart';

@RestApi()
abstract class ProofsApi {
  factory ProofsApi(Dio dio, {String? baseUrl}) = _ProofsApi;

  @POST('/proofs/upload-url')
  Future<PresignedUrlResponse> getUploadUrl(@Body() UploadUrlRequest request);

  @POST('/games/{gameId}/tiles/{tileId}/proofs')
  Future<TileProof> createProof(
    @Path('gameId') String gameId,
    @Path('tileId') String tileId,
    @Body() CreateProofRequest request,
  );

  @GET('/games/{gameId}/tiles/{tileId}/proofs')
  Future<List<TileProof>> getProofs(
    @Path('gameId') String gameId,
    @Path('tileId') String tileId,
  );

  @DELETE('/games/{gameId}/tiles/{tileId}/proofs/{proofId}')
  Future<void> deleteProof(
    @Path('gameId') String gameId,
    @Path('tileId') String tileId,
    @Path('proofId') String proofId,
  );

  @GET('/games/{gameId}/activity')
  Future<List<TileActivity>> getActivity(
    @Path('gameId') String gameId,
    @Query('limit') int? limit,
  );

  @GET('/games/{gameId}/stats')
  Future<ProofStats> getStats(@Path('gameId') String gameId);
}

