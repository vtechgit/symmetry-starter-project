import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/article.dart';

class ArticleWidget extends StatelessWidget {
  final ArticleEntity? article;
  final bool? isRemovable;
  final bool showJournalistBadge;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;

  const ArticleWidget({
    Key? key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.showJournalistBadge = false,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Container(
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
          child: Text(
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
                '· ${article?.publishedAt ?? ''}',
                style: TextStyle(color: secondaryColor, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (isRemovable == true)
          GestureDetector(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(Icons.chat_bubble_outline, '0', secondaryColor),
        _buildActionItem(Icons.repeat, '0', secondaryColor),
        _buildActionItem(Icons.favorite_border, '0', secondaryColor),
        _buildActionItem(Icons.ios_share_outlined, null, secondaryColor),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String? count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        if (count != null) ...[
          const SizedBox(width: 4),
          Text(count, style: TextStyle(color: color, fontSize: 13)),
        ],
      ],
    );
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
