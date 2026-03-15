import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/firestore/firestore_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import '../../../domain/entities/article.dart';

List<ArticleEntity> filterArticles(List<ArticleEntity> articles, String query) {
  if (query.isEmpty) return articles;
  final q = query.toLowerCase();
  return articles
      .where((a) =>
          (a.title?.toLowerCase().contains(q) ?? false) ||
          (a.author?.toLowerCase().contains(q) ?? false))
      .toList();
}

class FirestoreFeedPage extends StatefulWidget {
  const FirestoreFeedPage({Key? key}) : super(key: key);

  @override
  State<FirestoreFeedPage> createState() => _FirestoreFeedPageState();
}

class _FirestoreFeedPageState extends State<FirestoreFeedPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final filtered = filterArticles(articles, _searchQuery);
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<FirestoreArticlesBloc>().add(const GetFirestoreArticles());
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: filtered.isEmpty
                ? _buildNoResultsState(context)
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => ArticleWidget(
                      article: filtered[index],
                      showJournalistBadge: true,
                      onArticlePressed: (article) =>
                          Navigator.pushNamed(context, '/ArticleDetails', arguments: article),
                    ),
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
