import 'package:backend/config.dart';
import 'package:minio/minio.dart';

class R2Service {
  late final Minio _minio;
  late final String _bucketName;
  late final String _publicUrl;

  R2Service() {
    final accountId = Config.r2AccountId;
    final endpoint = '$accountId.r2.cloudflarestorage.com';

    _minio = Minio(
      endPoint: endpoint,
      accessKey: Config.r2AccessKeyId,
      secretKey: Config.r2SecretAccessKey,
      useSSL: true,
    );
    _bucketName = Config.r2BucketName;
    _publicUrl = Config.r2PublicUrl;
  }

  Future<String> generatePresignedUploadUrl({
    required String objectKey,
    int expirySeconds = 900,
  }) async {
    final url = await _minio.presignedPutObject(
      _bucketName,
      objectKey,
      expires: expirySeconds,
    );
    return url;
  }

  String getPublicUrl(String objectKey) {
    final baseUrl = _publicUrl.endsWith('/') ? _publicUrl : '$_publicUrl/';
    return '$baseUrl$objectKey';
  }

  String generateObjectKey({
    required String gameId,
    required String teamId,
    required String fileName,
  }) {
    final ext = fileName.split('.').last.toLowerCase();
    final uuid = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    return '$gameId/$teamId/$uuid.$ext';
  }
}

