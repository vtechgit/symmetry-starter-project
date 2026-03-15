import 'package:news_app_clean_architecture/features/ai_article/domain/entities/ai_generated_article.dart';

abstract class GenerateArticleState {
  const GenerateArticleState();
}

class GenerateArticleInitial extends GenerateArticleState {
  const GenerateArticleInitial();
}

class GenerateArticleLoading extends GenerateArticleState {
  const GenerateArticleLoading();
}

class GenerateArticleSuccess extends GenerateArticleState {
  final AiGeneratedArticle article;
  const GenerateArticleSuccess(this.article);
}

class GenerateArticleError extends GenerateArticleState {
  final String message;
  const GenerateArticleError(this.message);
}
