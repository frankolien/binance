import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/coin_about.dart';

abstract class CoinAboutRemoteDataSource {
  Future<CoinAbout> fetchAbout(String coinGeckoId);
}

/// Calls CoinGecko `/coins/{id}` (free public endpoint) and reduces the
/// (very large) JSON down to the fields the About section renders.
class CoinAboutRemoteDataSourceImpl implements CoinAboutRemoteDataSource {
  CoinAboutRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<CoinAbout> fetchAbout(String coinGeckoId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/coins/$coinGeckoId',
        queryParameters: const {
          'localization': false,
          'tickers': false,
          'market_data': true,
          'community_data': false,
          'developer_data': false,
          'sparkline': false,
        },
      );

      final data = response.data;
      if (data == null) {
        throw const ServerException('Empty CoinGecko response');
      }

      final marketData = data['market_data'] as Map<String, dynamic>?;
      final links = data['links'] as Map<String, dynamic>?;
      final description = data['description'] as Map<String, dynamic>?;

      return CoinAbout(
        id: data['id']?.toString() ?? coinGeckoId,
        symbol: (data['symbol']?.toString() ?? '').toLowerCase(),
        name: data['name']?.toString() ?? coinGeckoId,
        marketCapRank: _asInt(data['market_cap_rank']),
        marketCapUsd: _decimalUsd(marketData?['market_cap']),
        circulatingSupply: _asDecimal(marketData?['circulating_supply']),
        maxSupply: _asDecimal(marketData?['max_supply']),
        totalSupply: _asDecimal(marketData?['total_supply']),
        issuePriceUsd: _allTimeFiat(data['ico_data'], 'price_btc'),
        issueDate: _parseDate(data['genesis_date']),
        allTimeHighUsd: _decimalUsd(marketData?['ath']),
        allTimeHighDate: _parseDate(_pickUsd(marketData?['ath_date'])),
        allTimeLowUsd: _decimalUsd(marketData?['atl']),
        allTimeLowDate: _parseDate(_pickUsd(marketData?['atl_date'])),
        websiteUrl: _firstNonEmpty(links?['homepage']),
        blockExplorerUrl: _firstNonEmpty(links?['blockchain_site']),
        introduction: _stripHtml(description?['en']?.toString()),
      );
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'CoinGecko network error',
        statusCode: e.response?.statusCode,
      );
    } on FormatException catch (e) {
      throw ServerException('Bad CoinGecko response: ${e.message}');
    }
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static Decimal? _asDecimal(dynamic v) {
    if (v == null) return null;
    try {
      return Decimal.parse(v.toString());
    } catch (_) {
      return null;
    }
  }

  static Decimal? _decimalUsd(dynamic v) {
    if (v is! Map) return null;
    return _asDecimal(v['usd']);
  }

  static String? _pickUsd(dynamic v) {
    if (v is! Map) return null;
    return v['usd']?.toString();
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  static String? _firstNonEmpty(dynamic v) {
    if (v is! List) return null;
    for (final item in v) {
      final s = item?.toString().trim();
      if (s != null && s.isNotEmpty) return s;
    }
    return null;
  }

  static String? _stripHtml(String? input) {
    if (input == null || input.isEmpty) return null;
    return input.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  /// CoinGecko ICO data is rarely populated — kept for completeness, but the
  /// "Issue Price" field will gracefully render as null on most coins.
  static Decimal? _allTimeFiat(dynamic icoData, String key) {
    if (icoData is! Map) return null;
    return _asDecimal(icoData[key]);
  }
}
