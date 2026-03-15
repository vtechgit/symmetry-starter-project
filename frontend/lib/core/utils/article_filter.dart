import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

List<ArticleEntity> filterArticles(List<ArticleEntity> articles, String query) {
  if (query.isEmpty) return articles;
  final q = query.toLowerCase();
  return articles
      .where((a) =>
          (a.title?.toLowerCase().contains(q) ?? false) ||
          (a.author?.toLowerCase().contains(q) ?? false))
      .toList();
}
