import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/coin_meta.dart';

abstract class CoinMetaRepository {
  /// Fetches the top [limit] coins from CoinGecko, ordered by market cap desc.
  /// Result is keyed by lowercase symbol (e.g. 'btc' -> CoinMeta).
  Future<Either<Failure, Map<String, CoinMeta>>> getTopCoinsBySymbol({
    int limit = 250,
  });
}
