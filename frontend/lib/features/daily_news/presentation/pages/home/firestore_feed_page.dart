import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import '../../../domain/entities/article.dart';

class FirestoreFeedPage extends StatelessWidget {
  const FirestoreFeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FirestoreArticlesBloc, FirestoreArticlesState>(
      builder: (context, state) {
        if (state is FirestoreArticlesLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 2,
            ),
          );
        }
        if (state is FirestoreArticlesError) {
          return _buildErrorState(context);
        }
        if (state is FirestoreArticlesDone) {
          return _buildFeed(context, state.articles!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.article_outlined, color: secondaryColor, size: 48),
          const SizedBox(height: 12),
          Text(
            'Could not load journalist articles',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                context.read<FirestoreArticlesBloc>().add(const GetFirestoreArticles()),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeed(BuildContext context, List<ArticleEntity> articles) {
    if (articles.isEmpty) {
      return _buildEmptyState(context);
    }
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) => ArticleWidget(
        article: articles[index],
        showJournalistBadge: true,
        onArticlePressed: (article) =>
            Navigator.pushNamed(context, '/ArticleDetails', arguments: article),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_outlined, color: secondaryColor, size: 48),
          const SizedBox(height: 12),
          Text(
            'No articles published yet',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to publish a story',
            style: TextStyle(color: secondaryColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
