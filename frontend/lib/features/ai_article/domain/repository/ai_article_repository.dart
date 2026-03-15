import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import '../entities/ai_generated_article.dart';

abstract class AiArticleRepository {
  Future<DataState<AiGeneratedArticle>> generateArticle(String idea);
}
