import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';

class ArticleDetailsView extends StatelessWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: scaffoldColor,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Ionicons.chevron_back, color: Colors.white),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _onShareTapped,
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Ionicons.share_outline, color: Colors.white, size: 20),
          ),
        ),
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => _onBookmarkTapped(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Ionicons.bookmark_outline, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: article?.urlToImage ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surface,
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surface,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                  size: 48,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, scaffoldColor],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAuthorRow(context),
          const SizedBox(height: 16),
          _buildTitle(context),
          const SizedBox(height: 20),
          Divider(color: Theme.of(context).dividerColor, height: 1),
          const SizedBox(height: 20),
          _buildBody(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAuthorRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: colorScheme.primary,
          child: Text(
            _authorInitial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article?.author ?? 'Unknown',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Text(
                article?.publishedAt ?? '',
                style: TextStyle(color: secondaryColor, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      article?.title ?? '',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.3,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final description = article?.description ?? '';
    final content = article?.content ?? '';
    final body = [description, content].where((s) => s.isNotEmpty).join('\n\n');
    return Text(
      body,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
        height: 1.6,
      ),
    );
  }

  String get _authorInitial {
    final author = article?.author ?? 'U';
    return author.isNotEmpty ? author[0].toUpperCase() : 'U';
  }

  void _onShareTapped() {
    final text = [article?.title, article?.description]
        .where((s) => s != null && s.isNotEmpty)
        .join('\n\n');
    Share.share(text);
  }

  void _onBookmarkTapped(BuildContext context) {
    context.read<LocalArticleBloc>().add(SaveArticle(article!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Article saved')),
    );
  }
}
