import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/kline.dart';

abstract class KlinesRemoteDataSource {
  Future<List<Kline>> fetchKlines({
    required String symbol,
    required String interval,
    required int limit,
  });
}

/// Calls Binance public `/api/v3/klines`. Response is a JSON array of arrays,
/// so we decode positionally rather than via json_serializable.
class KlinesRemoteDataSourceImpl implements KlinesRemoteDataSource {
  KlinesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static const _path = '/api/v3/klines';

  @override
  Future<List<Kline>> fetchKlines({
    required String symbol,
    required String interval,
    required int limit,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path,
        queryParameters: {
          'symbol': symbol,
          'interval': interval,
          'limit': limit,
        },
      );

      final data = response.data;
      if (data is! List) {
        throw const ServerException('Unexpected klines response');
      }

      return data
          .whereType<List>()
          .map(_parseKline)
          .whereType<Kline>()
          .toList(growable: false);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } on FormatException catch (e) {
      throw ServerException('Bad klines response: ${e.message}');
    }
  }

  Kline? _parseKline(List<dynamic> row) {
    // Binance kline tuple: [openTime, open, high, low, close, volume, ...]
    if (row.length < 6) return null;
    try {
      return Kline(
        openTime: DateTime.fromMillisecondsSinceEpoch(
          (row[0] as num).toInt(),
          isUtc: true,
        ),
        open: Decimal.parse(row[1].toString()),
        high: Decimal.parse(row[2].toString()),
        low: Decimal.parse(row[3].toString()),
        close: Decimal.parse(row[4].toString()),
        volume: Decimal.parse(row[5].toString()),
      );
    } catch (_) {
      return null;
    }
  }
}
