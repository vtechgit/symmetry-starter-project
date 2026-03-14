import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class GetFirestoreArticlesUseCase implements UseCase<DataState<List<ArticleEntity>>, void> {
  @override
  Future<DataState<List<ArticleEntity>>> call({void params}) async {
    return const DataSuccess([
      ArticleEntity(
        author: 'Jane Doe',
        title: 'Breaking: Flutter Web Support Improves',
        description: 'Flutter team announces better web rendering performance.',
        content: 'The Flutter team has announced significant improvements to the web renderer, reducing load times and improving frame rates for complex UIs.',
        urlToImage: 'https://via.placeholder.com/400x200.png?text=Article+1',
        publishedAt: '2026-03-14',
      ),
      ArticleEntity(
        author: 'John Smith',
        title: 'Clean Architecture in Mobile Apps',
        description: 'Why separating concerns matters for large teams.',
        content: 'In large mobile codebases, Clean Architecture prevents tight coupling between UI, business logic, and data sources — making features easier to test and replace.',
        urlToImage: 'https://via.placeholder.com/400x200.png?text=Article+2',
        publishedAt: '2026-03-13',
      ),
    ]);
  }
}
