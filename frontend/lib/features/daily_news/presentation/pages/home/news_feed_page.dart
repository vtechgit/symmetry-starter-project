import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/utils/article_filter.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import '../../../domain/entities/article.dart';

class NewsFeedPage extends StatefulWidget {
  const NewsFeedPage({Key? key}) : super(key: key);

  @override
  State<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends State<NewsFeedPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return const _ArticleSkeletonList();
        }
        if (state is RemoteArticlesError) {
          return _ErrorView(
            onRetry: () => context.read<RemoteArticlesBloc>().add(const GetArticles()),
          );
        }
        if (state is RemoteArticlesDone) {
          return _buildFeed(context, state.articles!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildFeed(BuildContext context, List<ArticleEntity> articles) {
    final filtered = filterArticles(articles, _searchQuery);
    return Column(
      children: [
        _buildSearchBar(context),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<RemoteArticlesBloc>().add(const GetArticles());
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: filtered.isEmpty
                ? _buildNoResultsState(context)
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => ArticleWidget(
                      article: filtered[index],
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
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_outlined, color: secondaryColor, size: 48),
          const SizedBox(height: 12),
          Text(
            'Something went wrong',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Check your connection and try again',
            style: TextStyle(color: secondaryColor, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _ArticleSkeletonList extends StatefulWidget {
  const _ArticleSkeletonList();

  @override
  State<_ArticleSkeletonList> createState() => _ArticleSkeletonListState();
}

class _ArticleSkeletonListState extends State<_ArticleSkeletonList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) => ListView.builder(
        itemCount: 5,
        itemBuilder: (context, _) => _SkeletonCard(opacity: _animation.value),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double opacity;

  const _SkeletonCard({required this.opacity});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final divider = Theme.of(context).dividerColor;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        border: Border(bottom: BorderSide(color: divider, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmer(context, 36, 36, radius: 18),
              const SizedBox(width: 10),
              _shimmer(context, 120, 12),
            ],
          ),
          const SizedBox(height: 10),
          _shimmer(context, double.infinity, 14),
          const SizedBox(height: 6),
          _shimmer(context, 200, 14),
          const SizedBox(height: 10),
          _shimmer(context, double.infinity, 160, radius: 12),
        ],
      ),
    );
  }

  Widget _shimmer(BuildContext context, double width, double height, {double radius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
