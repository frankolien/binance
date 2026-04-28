import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ticker.dart';
import '../../domain/repositories/markets_repository.dart';
import '../datasources/markets_remote_datasource.dart';

class MarketsRepositoryImpl implements MarketsRepository {
  MarketsRepositoryImpl(this._remote);

  final MarketsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Ticker>>> getTickers({
    List<String>? symbols,
  }) async {
    try {
      final dtos = await _remote.fetchTickers(symbols: symbols);
      return Right(dtos.map((d) => d.toEntity()).toList(growable: false));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Ticker>> getTicker(String symbol) async {
    try {
      final dto = await _remote.fetchTicker(symbol);
      return Right(dto.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
