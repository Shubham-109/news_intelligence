import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Rounded network image with a quiet placeholder while it loads.
///
/// Images are cached on disk, so stories opened before still show their
/// pictures offline. When [url] is missing or fails to load, [fallbackUrl] is
/// tried before settling on the plain placeholder.
class ArticleImage extends StatelessWidget {
  const ArticleImage({
    super.key,
    required this.url,
    this.fallbackUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  final String? url;
  final String? fallbackUrl;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: _buildImage(context, url, fallbackUrl),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String? source, String? fallback) {
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
    );
    if (source == null) {
      return fallback == null
          ? placeholder
          : _buildImage(context, fallback, null);
    }

    // Decoding at display size keeps memory low in long lists.
    final displayWidth = width;
    final cacheWidth = displayWidth == null
        ? null
        : (displayWidth * MediaQuery.devicePixelRatioOf(context)).round();

    return CachedNetworkImage(
      imageUrl: source,
      fit: BoxFit.cover,
      memCacheWidth: cacheWidth,
      fadeInDuration: const Duration(milliseconds: 200),
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) =>
          fallback == null ? placeholder : _buildImage(context, fallback, null),
    );
  }
}
