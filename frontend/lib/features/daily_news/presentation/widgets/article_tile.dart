import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:news_app_clean_architecture/core/utils/auth_guard.dart';
import 'package:news_app_clean_architecture/core/utils/date_format_helper.dart';
import 'package:news_app_clean_architecture/injection_container.dart';
import '../../domain/entities/article.dart';
import '../bloc/article/social/social_bloc.dart';
import '../bloc/article/social/social_event.dart';
import '../bloc/article/social/social_state.dart';
import 'comments_bottom_sheet.dart';

class ArticleWidget extends StatelessWidget {
  final ArticleEntity? article;
  final bool? isRemovable;
  final bool showJournalistBadge;
  final bool isJournalistArticle;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onDelete;
  final void Function(ArticleEntity article)? onArticlePressed;

  const ArticleWidget({
    Key? key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.showJournalistBadge = false,
    this.isJournalistArticle = false,
    this.onRemove,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isJournalistArticle && article?.firestoreId != null) {
      return BlocProvider(
        key: ValueKey(article!.firestoreId),
        create: (_) => sl<SocialBloc>()
          ..add(SocialLoadRequested(
            articleId: article!.firestoreId!,
            initialLikeCount: article!.likeCount ?? 0,
            initialCommentCount: article!.commentCount ?? 0,
          )),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onTap,
          child: _buildTile(context),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: _buildTile(context),
    );
  }

  Widget _buildTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 8),
          _buildTitle(context),
          if (article?.description != null && article!.description!.isNotEmpty)
            _buildDescription(context),
          if (article?.urlToImage != null && article!.urlToImage!.isNotEmpty)
            _buildImage(context),
          const SizedBox(height: 10),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: colorScheme.primary,
          backgroundImage: (article?.authorPhotoURL?.isNotEmpty == true)
              ? CachedNetworkImageProvider(article!.authorPhotoURL!)
              : null,
          child: (article?.authorPhotoURL?.isNotEmpty == true)
              ? null
              : Text(
                  _authorInitial,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  article?.author ?? 'Unknown',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showJournalistBadge) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: colorScheme.primary, width: 0.5),
                  ),
                  child: Text(
                    'Journalist',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              Text(
                '· ${formatPublishedAt(article?.publishedAt)}',
                style: TextStyle(color: secondaryColor, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onDelete != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onDelete!(article!),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.delete_outline, color: secondaryColor, size: 18),
            ),
          ),
        if (isRemovable == true)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onRemove,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(Icons.close, color: secondaryColor, size: 18),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      article?.title ?? '',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        article!.description!,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium!.color,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final dividerColor = Theme.of(context).dividerColor;
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: article!.urlToImage!,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 180,
            color: dividerColor,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 180,
            color: dividerColor,
            child: Icon(Icons.broken_image_outlined, color: secondaryColor, size: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final secondaryColor = Theme.of(context).textTheme.bodyMedium!.color!;

    if (!isJournalistArticle) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildActionItem(Icons.ios_share_outlined, null, secondaryColor,
              onTap: _onShare),
        ],
      );
    }

    return BlocBuilder<SocialBloc, SocialState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem(
              Icons.chat_bubble_outline,
              '${state.commentCount}',
              secondaryColor,
              onTap: () => requireAuth(context, () {
                showCommentsBottomSheet(context, article!.firestoreId!);
              }),
            ),
            _buildActionItem(
              state.isLiked ? Icons.favorite : Icons.favorite_border,
              '${state.likeCount}',
              state.isLiked ? Colors.red : secondaryColor,
              onTap: () => requireAuth(context, () {
                context.read<SocialBloc>().add(LikeToggled(article!.firestoreId!));
              }),
            ),
            _buildActionItem(Icons.ios_share_outlined, null, secondaryColor,
                onTap: _onShare),
          ],
        );
      },
    );
  }

  Widget _buildActionItem(IconData icon, String? count, Color color,
      {VoidCallback? onTap}) {
    final content = Row(
      children: [
        Icon(icon, size: 18, color: color),
        if (count != null) ...[
          const SizedBox(width: 4),
          Text(count, style: TextStyle(color: color, fontSize: 13)),
        ],
      ],
    );
    if (onTap == null) return content;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: content,
      ),
    );
  }

  void _onShare() {
    final text = [article?.title, article?.description]
        .where((s) => s != null && s.isNotEmpty)
        .join('\n\n');
    Share.share(text);
  }

  String get _authorInitial {
    final author = article?.author ?? 'U';
    return author.isNotEmpty ? author[0].toUpperCase() : 'U';
  }

  void _onTap() {
    if (onArticlePressed != null) {
      onArticlePressed!(article!);
    }
  }

  void _onRemove() {
    if (onRemove != null) {
      onRemove!(article!);
    }
  }
}
