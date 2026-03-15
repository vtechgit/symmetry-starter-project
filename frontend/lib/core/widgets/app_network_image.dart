import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Displays a network image handling CORS for Flutter Web.
///
/// On web, [NetworkImage] is used with [WebHtmlElementStrategy.prefer] so the
/// browser renders it via an <img> element, bypassing cross-origin restrictions
/// on services like loremflickr that block XHR requests.
/// On mobile/desktop, [CachedNetworkImage] is used for efficient caching.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image(
        image: NetworkImage(
          url,
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        ),
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: placeholder != null
            ? (_, child, progress) =>
                progress == null ? child : placeholder!
            : null,
        errorBuilder:
            errorWidget != null ? (_, __, ___) => errorWidget! : null,
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder != null ? (_, __) => placeholder! : null,
      errorWidget: errorWidget != null ? (_, __, ___) => errorWidget! : null,
    );
  }
}
