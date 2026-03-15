import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/firestore_article_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/storage_service.dart';

class RemoteArticleDataSources {
  final NewsApiService newsApi;
  final FirestoreArticleService firestore;
  final StorageService storage;

  const RemoteArticleDataSources({
    required this.newsApi,
    required this.firestore,
    required this.storage,
  });
}
