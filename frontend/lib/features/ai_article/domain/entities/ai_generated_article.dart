import 'package:equatable/equatable.dart';

class AiGeneratedArticle extends Equatable {
  final String title;
  final String description;
  final String content;
  final String thumbnailUrl;

  const AiGeneratedArticle({
    required this.title,
    required this.description,
    required this.content,
    required this.thumbnailUrl,
  });

  @override
  List<Object?> get props => [title, description, content, thumbnailUrl];
}
