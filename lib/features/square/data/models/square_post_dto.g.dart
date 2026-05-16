// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'square_post_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SquarePostDto _$SquarePostDtoFromJson(Map<String, dynamic> json) =>
    SquarePostDto(
      id: json['id'] as String,
      publishedOn: (json['published_on'] as num).toInt(),
      title: json['title'] as String,
      body: json['body'] as String,
      imageurl: json['imageurl'] as String?,
      url: json['url'] as String,
      source: json['source'] as String,
      categories: json['categories'] as String,
      tags: json['tags'] as String,
      sourceInfo: json['source_info'] == null
          ? null
          : SourceInfoDto.fromJson(json['source_info'] as Map<String, dynamic>),
    );

SourceInfoDto _$SourceInfoDtoFromJson(Map<String, dynamic> json) =>
    SourceInfoDto(name: json['name'] as String, img: json['img'] as String?);
