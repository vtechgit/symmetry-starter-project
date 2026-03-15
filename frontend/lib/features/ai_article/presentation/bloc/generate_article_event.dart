abstract class GenerateArticleEvent {
  const GenerateArticleEvent();
}

class GenerateArticleRequested extends GenerateArticleEvent {
  final String idea;
  const GenerateArticleRequested(this.idea);
}
