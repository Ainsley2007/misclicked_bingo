import 'package:backend/config.dart';
import 'package:minio/minio.dart';

class R2Service {
  R2Service() {
    final accountId = Config.r2AccountId;
    final accessKey = Config.r2AccessKeyId;
    final secretKey = Config.r2SecretAccessKey;
    _bucketName = Config.r2BucketName;
    _publicUrl = Config.r2PublicUrl;

    if (accountId.isEmpty || accessKey.isEmpty || secretKey.isEmpty) {
      throw StateError(
        'R2 configuration missing. Required env vars: '
        'R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_BUCKET_NAME, R2_PUBLIC_URL. '
        'Current values - Account ID: ${accountId.isEmpty ? "MISSING" : "set"}, '
        'Access Key: ${accessKey.isEmpty ? "MISSING" : "set"}, '
        'Secret Key: ${secretKey.isEmpty ? "MISSING" : "set"}',
      );
    }

    final endpoint = '$accountId.r2.cloudflarestorage.com';

    _minio = Minio(
      endPoint: endpoint,
      accessKey: accessKey,
      secretKey: secretKey,
      useSSL: true,
    );
  }
  late final Minio _minio;
  late final String _bucketName;
  late final String _publicUrl;

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
