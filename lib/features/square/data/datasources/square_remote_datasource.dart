import 'package:dio/dio.dart';

import '../../../../core/constants/app_env.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/square_repository.dart';
import '../models/square_post_dto.dart';

abstract class SquareRemoteDataSource {
  Future<List<SquarePostDto>> fetchPosts({
    required SquareCategory category,
    int? beforeUnixSeconds,
  });
}

class SquareRemoteDataSourceImpl implements SquareRemoteDataSource {
  SquareRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static const _path = '/data/v2/news/';

  // CryptoCompare's `categories` filter is OR-joined. Discover/Hot leave it
  // empty (full feed); News narrows to news-ish buckets.
  static const _newsCategories = 'Trading|Mining|Regulation|Sponsored|Market';

  @override
  Future<List<SquarePostDto>> fetchPosts({
    required SquareCategory category,
    int? beforeUnixSeconds,
  }) async {
    final query = <String, dynamic>{
      'lang': 'EN',
      if (category == SquareCategory.news) 'categories': _newsCategories,
      if (beforeUnixSeconds != null) 'lTs': beforeUnixSeconds,
      if (AppEnv.cryptoCompareApiKey.isNotEmpty)
        'api_key': AppEnv.cryptoCompareApiKey,
    };

    try {
      final response =
          await _dio.get<Map<String, dynamic>>(_path, queryParameters: query);
      final body = response.data;
      // CryptoCompare returns HTTP 200 even for auth/rate-limit errors; the
      // real status is in the body's "Response" / "Message" fields.
      if (body?['Response'] == 'Error') {
        throw ServerException(
          body?['Message']?.toString() ?? 'CryptoCompare error',
        );
      }
      final data = body?['Data'];
      if (data is! List) {
        throw const ServerException('Unexpected CryptoCompare response shape');
      }
      return data
          .cast<Map<String, dynamic>>()
          .map(SquarePostDto.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'CryptoCompare network error',
        statusCode: e.response?.statusCode,
      );
    } on FormatException catch (e) {
      throw ServerException('Bad CryptoCompare response: ${e.message}');
    }
  }
}
