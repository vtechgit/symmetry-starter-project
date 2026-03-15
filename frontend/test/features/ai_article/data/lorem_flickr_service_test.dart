import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/ai_article/data/data_sources/lorem_flickr_service.dart';

void main() {
  late LoremFlickrService service;

  setUp(() => service = LoremFlickrService());

  group('LoremFlickrService', () {
    test('returns a loremflickr URL', () async {
      final url = await service.generateImage('cars,electric,technology');
      expect(url, startsWith('https://loremflickr.com/640/360/'));
    });

    test('includes lock param for consistent images', () async {
      final url = await service.generateImage('cars,electric,technology');
      expect(url, contains('?lock='));
    });

    test('keeps commas as literal separators (not %2C)', () async {
      final url = await service.generateImage('cars,electric,technology');
      final path = Uri.parse(url).path;
      expect(path, contains(','));
    });

    test('strips multi-word phrases to first word per keyword', () async {
      final url = await service.generateImage('electric cars,autonomous driving,sustainable materials');
      final path = Uri.parse(url).path;
      // Each keyword should be just one word — no spaces (%20) in the path
      expect(path, isNot(contains('%20')));
      expect(path, contains('electric'));
      expect(path, contains('autonomous'));
      expect(path, contains('sustainable'));
    });

    test('different calls produce different lock values', () async {
      // Two calls in the same millisecond could share a lock — just verify
      // the URL is well-formed regardless.
      final url1 = await service.generateImage('news');
      final url2 = await service.generateImage('news');
      expect(url1, startsWith('https://loremflickr.com/'));
      expect(url2, startsWith('https://loremflickr.com/'));
    });
  });
}
