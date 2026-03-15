import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/bookmark/bookmark_bloc.dart';
import '../../bloc/article/bookmark/bookmark_event.dart';
import '../../bloc/article/bookmark/bookmark_state.dart';
import '../../widgets/article_tile.dart';

class SavedArticlesPage extends StatelessWidget {
  const SavedArticlesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return _buildSignInPrompt(context);
        }
        return BlocBuilder<BookmarkBloc, BookmarkState>(
          builder: (context, state) {
            if (state is BookmarkLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                ),
              );
            }
            if (state is BookmarkDone) {
              return _buildArticlesList(context, state.articles!);
            }
            return const SizedBox();
          },
        );
      },
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Ionicons.bookmark_outline, color: secondaryColor, size: 48),
          const SizedBox(height: 12),
          Text(
            'Sign in to see your bookmarks',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your saved articles are linked to your account',
            style: TextStyle(color: secondaryColor, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/Login'),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesList(BuildContext context, List<ArticleEntity> articles) {
    if (articles.isEmpty) {
      return _buildEmptyState(context);
    }
    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) => ArticleWidget(
        article: articles[index],
        isRemovable: true,
        isJournalistArticle: articles[index].firestoreId != null,
        onRemove: (article) =>
            context.read<BookmarkBloc>().add(RemoveBookmark(article)),
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
          Icon(Ionicons.bookmark_outline, color: secondaryColor, size: 48),
          const SizedBox(height: 12),
          Text(
            'Nothing saved yet',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Articles you save will appear here',
            style: TextStyle(color: secondaryColor, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
