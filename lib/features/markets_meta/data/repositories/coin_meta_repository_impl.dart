import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/coin_meta.dart';
import '../../domain/repositories/coin_meta_repository.dart';
import '../datasources/coin_gecko_remote_datasource.dart';

class CoinMetaRepositoryImpl implements CoinMetaRepository {
  CoinMetaRepositoryImpl(this._remote);

  final CoinGeckoRemoteDataSource _remote;

  Map<String, CoinMeta>? _cache;
  DateTime? _fetchedAt;
  static const _cacheTtl = Duration(minutes: 5);

  @override
  Future<Either<Failure, Map<String, CoinMeta>>> getTopCoinsBySymbol({
    int limit = 250,
  }) async {
    if (_cache != null && _fetchedAt != null) {
      final age = DateTime.now().difference(_fetchedAt!);
      if (age < _cacheTtl) {
        return Right(_cache!);
      }
    }

    try {
      final dtos = await _remote.fetchMarkets(perPage: limit);
      final map = <String, CoinMeta>{};
      for (final dto in dtos) {
        final entity = dto.toEntity();
        // First-seen wins for collisions (e.g. multiple coins with the same
        // ticker — keep the higher-ranked one since list is rank-ordered).
        map.putIfAbsent(entity.symbol, () => entity);
      }
      _cache = map;
      _fetchedAt = DateTime.now();
      return Right(map);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
