import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/square_post.dart';

part 'square_post_dto.g.dart';

// CryptoCompare cashtag pattern: $TICKER (2-10 uppercase letters / digits).
final _cashtagRegex = RegExp(r'\$([A-Z][A-Z0-9]{1,9})\b');

@JsonSerializable(createToJson: false)
class SquarePostDto {
  const SquarePostDto({
    required this.id,
    required this.publishedOn,
    required this.title,
    required this.body,
    required this.imageurl,
    required this.url,
    required this.source,
    required this.categories,
    required this.tags,
    required this.sourceInfo,
  });

  factory SquarePostDto.fromJson(Map<String, dynamic> json) =>
      _$SquarePostDtoFromJson(json);

  final String id;
  @JsonKey(name: 'published_on') final int publishedOn;
  final String title;
  final String body;
  final String? imageurl;
  final String url;
  final String source;
  final String categories;
  final String tags;
  @JsonKey(name: 'source_info') final SourceInfoDto? sourceInfo;

  SquarePost toEntity() {
    // Body is a long article; for card display we prefer title + lead.
    final cardBody = title.isNotEmpty ? title : body;
    final mentions = _cashtagRegex
        .allMatches('$title $body')
        .map((m) => m.group(1)!)
        .toSet()
        .toList(growable: false);
    final cats = categories
        .split('|')
        .where((c) => c.trim().isNotEmpty)
        .toList(growable: false);
    return SquarePost(
      id: id,
      authorName: sourceInfo?.name ?? source,
      authorAvatarUrl: sourceInfo?.img,
      publishedAt:
          DateTime.fromMillisecondsSinceEpoch(publishedOn * 1000, isUtc: true)
              .toLocal(),
      body: cardBody,
      imageUrl: (imageurl != null && imageurl!.isNotEmpty) ? imageurl : null,
      tickerMentions: mentions,
      categories: cats,
      sourceUrl: url,
    );
  }
}

@JsonSerializable(createToJson: false)
class SourceInfoDto {
  const SourceInfoDto({required this.name, required this.img});

  factory SourceInfoDto.fromJson(Map<String, dynamic> json) =>
      _$SourceInfoDtoFromJson(json);

  final String name;
  final String? img;
}
