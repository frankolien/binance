import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/coin_gecko_market_dto.dart';

abstract class CoinGeckoRemoteDataSource {
  Future<List<CoinGeckoMarketDto>> fetchMarkets({int perPage = 250});
}

class CoinGeckoRemoteDataSourceImpl implements CoinGeckoRemoteDataSource {
  CoinGeckoRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static const _path = '/coins/markets';

  @override
  Future<List<CoinGeckoMarketDto>> fetchMarkets({int perPage = 250}) async {
    try {
      final response = await _dio.get<dynamic>(
        _path,
        queryParameters: {
          'vs_currency': 'usd',
          'order': 'market_cap_desc',
          'per_page': perPage,
          'page': 1,
          'sparkline': false,
        },
      );

      final data = response.data;
      if (data is! List) {
        throw const ServerException('Unexpected CoinGecko response');
      }
      return data
          .cast<Map<String, dynamic>>()
          .map(CoinGeckoMarketDto.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'CoinGecko network error',
        statusCode: e.response?.statusCode,
      );
    } on FormatException catch (e) {
      throw ServerException('Bad CoinGecko response: ${e.message}');
    }
  }
}
