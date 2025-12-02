import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  const CachedImage({required this.imageUrl, this.width, this.height, this.fit = BoxFit.cover, this.placeholder, this.errorWidget, super.key});

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (context, url, error) => errorWidget ?? const Icon(Icons.error_outline_rounded),
    );
  }
}

class CachedAvatar extends StatelessWidget {
  const CachedAvatar({this.imageUrl, required this.fallback, this.radius = 20, super.key});

  final String? imageUrl;
  final Widget fallback;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(radius: radius, child: fallback);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(radius: radius, backgroundImage: imageProvider),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        child: const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => CircleAvatar(radius: radius, child: fallback),
    );
  }
}
