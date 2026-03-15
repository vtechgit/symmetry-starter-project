import 'ai_image_provider.dart';

/// Returns a thumbnail URL from loremflickr.com using topic keywords.
/// No API key required. The browser resolves the URL directly via Image.network.
/// To swap to a real image-generation API, implement [AiImageProvider] in a
/// new class and update the registration in injection_container.dart.
class LoremFlickrService implements AiImageProvider {
  @override
  Future<String> generateImage(String keywords) async {
    // keywords is a comma-separated list like "cars,electric,2026"
    // loremflickr only accepts single words — take the first word of each
    // keyword to guard against multi-word phrases the LLM may produce.
    // Keep commas literal: loremflickr uses them as multi-keyword separators
    // and breaks if they are %2C-encoded.
    final encodedKeywords = keywords
        .split(',')
        .map((k) => Uri.encodeComponent(k.trim().split(' ').first))
        .join(',');
    // lock param pins loremflickr to a specific image for this keyword+lock
    // combination — the same URL will always resolve to the same photo.
    final lock = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'https://loremflickr.com/640/360/$encodedKeywords?lock=$lock';
  }
}
