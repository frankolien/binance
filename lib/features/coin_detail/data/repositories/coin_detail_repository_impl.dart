import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../markets_meta/domain/repositories/coin_meta_repository.dart';
import '../../domain/entities/coin_about.dart';
import '../../domain/entities/coin_timeframe.dart';
import '../../domain/entities/kline.dart';
import '../../domain/repositories/coin_detail_repository.dart';
import '../datasources/coin_about_remote_datasource.dart';
import '../datasources/klines_remote_datasource.dart';

class CoinDetailRepositoryImpl implements CoinDetailRepository {
  CoinDetailRepositoryImpl({
    required KlinesRemoteDataSource klines,
    required CoinAboutRemoteDataSource about,
    required CoinMetaRepository meta,
  })  : _klines = klines,
        _about = about,
        _meta = meta;

  final KlinesRemoteDataSource _klines;
  final CoinAboutRemoteDataSource _about;
  final CoinMetaRepository _meta;

  @override
  Future<Either<Failure, List<Kline>>> getKlines({
    required String symbol,
    required CoinTimeframe timeframe,
  }) async {
    try {
      final list = await _klines.fetchKlines(
        symbol: symbol,
        interval: timeframe.binanceInterval,
        limit: timeframe.candleLimit,
      );
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CoinAbout?>> getAbout(String tickerSymbol) async {
    try {
      // Resolve ticker (e.g. 'BTC') -> CoinGecko id ('bitcoin') via the
      // markets_meta repository, which already caches the top-coin list.
      final metaResult = await _meta.getTopCoinsBySymbol();
      final coinGeckoId = metaResult.fold<String?>(
        (_) => null,
        (map) => map[tickerSymbol.toLowerCase()]?.id,
      );

      if (coinGeckoId == null) {
        return const Right(null);
      }

      final about = await _about.fetchAbout(coinGeckoId);
      return Right(about);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
