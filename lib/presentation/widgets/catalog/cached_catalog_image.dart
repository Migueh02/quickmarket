import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Imagen de catálogo con caché en disco y placeholder tipo shimmer.
class CachedCatalogImage extends StatelessWidget {
  const CachedCatalogImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.height,
    this.width,
  });

  final String imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;
    if (imageUrl.isEmpty) {
      return _placeholder(context, radius);
    }
    final w = width;
    final memCacheWidth =
        (w != null && w.isFinite && w > 0) ? (w * 2).round() : null;
    final child = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      // En web, `double.infinity.toInt()` lanza `Unsupported operation: Infinity`.
      // Solo aplicamos `memCacheWidth` cuando el ancho es finito.
      memCacheWidth: memCacheWidth,
      placeholder: (_, __) => _shimmer(radius),
      errorWidget: (_, __, ___) => _placeholder(context, radius),
    );
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: radius,
        child: SizedBox(height: height, width: width, child: child),
      );
    }
    return SizedBox(height: height, width: width, child: child);
  }

  Widget _shimmer(BorderRadius radius) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, BorderRadius radius) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: radius,
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
