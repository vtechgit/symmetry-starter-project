import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/core/utils/article_filter.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/bookmark/bookmark_bloc.dart';
import '../../bloc/article/bookmark/bookmark_event.dart';
import '../../bloc/article/bookmark/bookmark_state.dart';
import '../../widgets/article_tile.dart';

class SavedArticlesPage extends StatefulWidget {
  const SavedArticlesPage({Key? key}) : super(key: key);

  @override
  State<SavedArticlesPage> createState() => _SavedArticlesPageState();
}

class _SavedArticlesPageState extends State<SavedArticlesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final filtered = filterArticles(articles, _searchQuery);
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(
          child: filtered.isEmpty
              ? _buildNoResultsState(context)
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => ArticleWidget(
                    article: filtered[index],
                    isRemovable: true,
                    isJournalistArticle: filtered[index].firestoreId != null,
                    onRemove: (article) =>
                        context.read<BookmarkBloc>().add(RemoveBookmark(article)),
                    onArticlePressed: (article) =>
                        Navigator.pushNamed(context, '/ArticleDetails', arguments: article),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final divider = Theme.of(context).dividerColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divider, width: 0.5)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by title or author...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;
    return ListView(
      children: [
        SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, color: secondaryColor, size: 48),
                const SizedBox(height: 12),
                Text(
                  'No results for "$_searchQuery"',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
