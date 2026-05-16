import 'package:equatable/equatable.dart';

class SquarePost extends Equatable {
  const SquarePost({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.publishedAt,
    required this.body,
    required this.imageUrl,
    required this.tickerMentions,
    required this.categories,
    required this.sourceUrl,
  });

  final String id;
  final String authorName;
  final String? authorAvatarUrl;
  final DateTime publishedAt;
  final String body;
  final String? imageUrl;
  final List<String> tickerMentions;
  final List<String> categories;
  final String sourceUrl;

  @override
  List<Object?> get props => [
        id,
        authorName,
        authorAvatarUrl,
        publishedAt,
        body,
        imageUrl,
        tickerMentions,
        categories,
        sourceUrl,
      ];
}
