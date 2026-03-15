import 'package:equatable/equatable.dart';
import '../../../../domain/entities/article.dart';

abstract class BookmarkEvent extends Equatable {
  final ArticleEntity? article;
  const BookmarkEvent({this.article});

  @override
  List<Object?> get props => [article];
}

class GetBookmarks extends BookmarkEvent {
  const GetBookmarks();
}

class SaveBookmark extends BookmarkEvent {
  const SaveBookmark(ArticleEntity article) : super(article: article);
}

class RemoveBookmark extends BookmarkEvent {
  const RemoveBookmark(ArticleEntity article) : super(article: article);
}
