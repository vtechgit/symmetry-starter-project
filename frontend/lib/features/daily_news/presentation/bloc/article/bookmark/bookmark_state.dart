import 'package:equatable/equatable.dart';
import '../../../../domain/entities/article.dart';

abstract class BookmarkState extends Equatable {
  final List<ArticleEntity>? articles;
  const BookmarkState({this.articles});

  @override
  List<Object?> get props => [articles];
}

class BookmarkLoading extends BookmarkState {
  const BookmarkLoading();
}

class BookmarkDone extends BookmarkState {
  const BookmarkDone(List<ArticleEntity> articles) : super(articles: articles);
}
