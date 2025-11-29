import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'proof_request.g.dart';

@JsonSerializable()
class UploadUrlRequest extends Equatable {
  final String gameId;
  final String fileName;

  const UploadUrlRequest({
    required this.gameId,
    required this.fileName,
  });

  factory UploadUrlRequest.fromJson(Map<String, dynamic> json) =>
      _$UploadUrlRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UploadUrlRequestToJson(this);

  @override
  List<Object?> get props => [gameId, fileName];
}

@JsonSerializable()
class PresignedUrlResponse extends Equatable {
  final String uploadUrl;
  final String publicUrl;
  final String objectKey;

  const PresignedUrlResponse({
    required this.uploadUrl,
    required this.publicUrl,
    required this.objectKey,
  });

  factory PresignedUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$PresignedUrlResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PresignedUrlResponseToJson(this);

  @override
  List<Object?> get props => [uploadUrl, publicUrl, objectKey];
}

@JsonSerializable()
class CreateProofRequest extends Equatable {
  final String imageUrl;

  const CreateProofRequest({required this.imageUrl});

  factory CreateProofRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProofRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateProofRequestToJson(this);

  @override
  List<Object?> get props => [imageUrl];
}

