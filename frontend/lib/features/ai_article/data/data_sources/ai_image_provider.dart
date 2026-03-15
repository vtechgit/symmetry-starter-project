abstract class AiImageProvider {
  /// Returns a URL for a thumbnail image matching [prompt].
  Future<String> generateImage(String prompt);
}
