import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/coin_about.dart';
import '../entities/coin_timeframe.dart';
import '../entities/kline.dart';

abstract class CoinDetailRepository {
  Future<Either<Failure, List<Kline>>> getKlines({
    required String symbol,
    required CoinTimeframe timeframe,
  });

  /// Fetches About data from CoinGecko by lowercase ticker (e.g. 'btc').
  /// Returns null on the Right side if the coin couldn't be matched.
  Future<Either<Failure, CoinAbout?>> getAbout(String tickerSymbol);
}
