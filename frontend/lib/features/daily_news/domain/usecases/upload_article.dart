import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class UploadArticleUseCase implements UseCase<DataState<void>, ArticleEntity> {
  @override
  Future<DataState<void>> call({ArticleEntity? params}) async {
    // Mock: simulates a successful upload to Firestore
    return const DataSuccess(null);
  }
}
