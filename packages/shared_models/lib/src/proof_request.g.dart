// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proof_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadUrlRequest _$UploadUrlRequestFromJson(Map<String, dynamic> json) =>
    UploadUrlRequest(
      gameId: json['gameId'] as String,
      fileName: json['fileName'] as String,
    );

Map<String, dynamic> _$UploadUrlRequestToJson(UploadUrlRequest instance) =>
    <String, dynamic>{'gameId': instance.gameId, 'fileName': instance.fileName};

PresignedUrlResponse _$PresignedUrlResponseFromJson(
  Map<String, dynamic> json,
) => PresignedUrlResponse(
  uploadUrl: json['uploadUrl'] as String,
  publicUrl: json['publicUrl'] as String,
  objectKey: json['objectKey'] as String,
);

Map<String, dynamic> _$PresignedUrlResponseToJson(
  PresignedUrlResponse instance,
) => <String, dynamic>{
  'uploadUrl': instance.uploadUrl,
  'publicUrl': instance.publicUrl,
  'objectKey': instance.objectKey,
};

CreateProofRequest _$CreateProofRequestFromJson(Map<String, dynamic> json) =>
    CreateProofRequest(imageUrl: json['imageUrl'] as String);

Map<String, dynamic> _$CreateProofRequestToJson(CreateProofRequest instance) =>
    <String, dynamic>{'imageUrl': instance.imageUrl};
