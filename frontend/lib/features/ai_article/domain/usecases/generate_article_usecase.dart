import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import '../entities/ai_generated_article.dart';
import '../repository/ai_article_repository.dart';

class GenerateArticleUseCase implements UseCase<DataState<AiGeneratedArticle>, String> {
  final AiArticleRepository _repository;

  GenerateArticleUseCase(this._repository);

  @override
  Future<DataState<AiGeneratedArticle>> call({String? params}) {
    return _repository.generateArticle(params ?? '');
  }
}
