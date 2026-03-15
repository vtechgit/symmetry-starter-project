import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/widgets/app_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ionicons/ionicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:news_app_clean_architecture/core/utils/auth_guard.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/usecases/delete_article.dart';
import '../../../domain/usecases/save_article.dart';
import '../../bloc/article/bookmark/bookmark_bloc.dart';
import '../../bloc/article/bookmark/bookmark_event.dart';
import '../../bloc/article/bookmark/bookmark_state.dart';
import '../../bloc/article/social/social_bloc.dart';
import '../../bloc/article/social/social_event.dart';
import '../../bloc/article/social/social_state.dart';
import '../../widgets/comments_bottom_sheet.dart';

class ArticleDetailsView extends StatelessWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  bool get _isJournalistArticle => article?.firestoreId != null;

  @override
  Widget build(BuildContext context) {
    Widget child = BlocProvider(
      create: (_) => sl<BookmarkBloc>()..add(const GetBookmarks()),
      child: Builder(builder: _buildScaffold),
    );
    if (_isJournalistArticle) {
      child = BlocProvider(
        create: (_) => sl<SocialBloc>()
          ..add(SocialLoadRequested(
            articleId: article!.firestoreId!,
            initialLikeCount: article!.likeCount ?? 0,
            initialCommentCount: article!.commentCount ?? 0,
          )),
        child: child,
      );
    }
    return child;
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    final authState = context.watch<AuthBloc>().state;
    final currentUid = authState is AuthAuthenticated ? authState.user.uid : null;
    final isOwner = currentUid != null && article?.authorId == currentUid;

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
        if (isOwner && _isJournalistArticle)
          GestureDetector(
            onTap: () => _onUnpublish(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
            ),
          ),
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
        BlocBuilder<BookmarkBloc, BookmarkState>(
          builder: (context, bookmarkState) {
            final saved = _isBookmarked(bookmarkState);
            return GestureDetector(
              onTap: () => _onBookmarkTapped(context, saved),
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  saved ? Ionicons.bookmark : Ionicons.bookmark_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(
              url: article?.urlToImage ?? '',
              fit: BoxFit.cover,
              placeholder: Container(
                color: Theme.of(context).colorScheme.surface,
              ),
              errorWidget: Container(
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
          if (_isJournalistArticle) ...[
            const SizedBox(height: 24),
            _buildSocialBar(context),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSocialBar(BuildContext context) {
    return BlocBuilder<SocialBloc, SocialState>(
      builder: (context, state) {
        final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;
        return Row(
          children: [
            _socialButton(
              icon: Icons.chat_bubble_outline,
              count: state.commentCount,
              color: secondaryColor,
              onTap: () => requireAuth(context, () {
                showCommentsBottomSheet(context, article!.firestoreId!);
              }),
            ),
            const SizedBox(width: 24),
            _socialButton(
              icon: state.isLiked ? Icons.favorite : Icons.favorite_border,
              count: state.likeCount,
              color: state.isLiked ? Colors.red : secondaryColor,
              onTap: () => requireAuth(context, () {
                context.read<SocialBloc>().add(LikeToggled(article!.firestoreId!));
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _socialButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 4),
          Text('$count', style: TextStyle(color: color, fontSize: 13)),
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

  bool _isBookmarked(BookmarkState state) {
    if (state is! BookmarkDone || state.articles == null) return false;
    return state.articles!.any((a) =>
        (article?.firestoreId != null && a.firestoreId == article?.firestoreId) ||
        (article?.url != null && a.url == article?.url));
  }

  void _onBookmarkTapped(BuildContext context, bool isSaved) {
    requireAuth(context, () async {
      if (isSaved) {
        context.read<BookmarkBloc>().add(RemoveBookmark(article!));
      } else {
        await sl<SaveArticleUseCase>()(params: article!);
        context.read<BookmarkBloc>().add(const GetBookmarks());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article saved')),
          );
        }
      }
    });
  }

  void _onUnpublish(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unpublish article?'),
        content: const Text('This will permanently remove your article.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await sl<DeleteArticleUseCase>().call(params: article!.firestoreId!);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Unpublish', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
