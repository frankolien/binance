import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/relative_time.dart';
import '../../domain/entities/square_post.dart';

class SquarePostCard extends StatelessWidget {
  const SquarePostCard({super.key, required this.post, this.onDismiss});

  final SquarePost post;
  final VoidCallback? onDismiss;

  static final _cashtagRegex = RegExp(r'\$([A-Z][A-Z0-9]{1,9})\b');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(post: post, onDismiss: onDismiss),
          const SizedBox(height: 8),
          _Body(body: post.body, textStyle: theme.textTheme.bodyLarge!),
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: AppColors.lightSurfaceAlt),
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.lightSurfaceAlt),
                ),
              ),
            ),
          ],
          if (post.tickerMentions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in post.tickerMentions.take(3))
                  _TickerPill(symbol: t),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const _ActionRow(),
          const SizedBox(height: 4),
          Divider(height: 1, color: AppColors.lightLine),
        ],
      ),
    );
  }

  static Widget buildBody(String body, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    var cursor = 0;
    for (final m in _cashtagRegex.allMatches(body)) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: body.substring(cursor, m.start)));
      }
      spans.add(TextSpan(
        text: body.substring(m.start, m.end),
        style: const TextStyle(
          color: AppColors.brandYellowPressed,
          fontWeight: FontWeight.w600,
        ),
      ));
      cursor = m.end;
    }
    if (cursor < body.length) {
      spans.add(TextSpan(text: body.substring(cursor)));
    }
    return RichText(
      text: TextSpan(style: baseStyle, children: spans),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.post, this.onDismiss});

  final SquarePost post;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.lightSurfaceAlt,
          backgroundImage: post.authorAvatarUrl != null
              ? CachedNetworkImageProvider(post.authorAvatarUrl!)
              : null,
          child: post.authorAvatarUrl == null
              ? Text(
                  post.authorName.isNotEmpty
                      ? post.authorName[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.bodyLarge,
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    post.authorName,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '· ${formatRelativeTime(post.publishedAt)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        if (onDismiss != null)
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            iconSize: 18,
            onPressed: onDismiss,
            icon: const Icon(Icons.close, color: AppColors.lightTextTertiary),
          ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.body, required this.textStyle});

  final String body;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) =>
      SquarePostCard.buildBody(body, textStyle);
}

class _TickerPill extends StatelessWidget {
  const _TickerPill({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightSurfaceAlt,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        symbol,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _ActionIcon(icon: PhosphorIconsRegular.chatCircle),
        _ActionIcon(icon: PhosphorIconsRegular.repeat),
        _ActionIcon(icon: PhosphorIconsRegular.thumbsUp),
        _ActionIcon(icon: PhosphorIconsRegular.chartBar),
        _ActionIcon(icon: PhosphorIconsRegular.shareNetwork),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 18, color: AppColors.lightTextTertiary);
  }
}
