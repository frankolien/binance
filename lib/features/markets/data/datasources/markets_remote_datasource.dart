import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/ticker_dto.dart';

abstract class MarketsRemoteDataSource {
  Future<List<TickerDto>> fetchTickers({List<String>? symbols});

  Future<TickerDto> fetchTicker(String symbol);
}

class MarketsRemoteDataSourceImpl implements MarketsRemoteDataSource {
  MarketsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static const _path = '/api/v3/ticker/24hr';

  @override
  Future<List<TickerDto>> fetchTickers({List<String>? symbols}) async {
    try {
      final query = <String, dynamic>{};
      if (symbols != null && symbols.isNotEmpty) {
        query['symbols'] = jsonEncode(symbols);
      }

      final response = await _dio.get<dynamic>(_path,
          queryParameters: query.isEmpty ? null : query);

      final data = response.data;
      if (data is! List) {
        throw const ServerException('Unexpected response shape');
      }
      return data
          .cast<Map<String, dynamic>>()
          .map(TickerDto.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } on FormatException catch (e) {
      throw ServerException('Bad response: ${e.message}');
    }
  }

  @override
  Future<TickerDto> fetchTicker(String symbol) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _path,
        queryParameters: {'symbol': symbol},
      );
      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty response');
      }
      return TickerDto.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } on FormatException catch (e) {
      throw ServerException('Bad response: ${e.message}');
    }
  }
}
