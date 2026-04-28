import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/ticker.dart';

abstract class MarketsRepository {
  Future<Either<Failure, List<Ticker>>> getTickers({List<String>? symbols});

  Future<Either<Failure, Ticker>> getTicker(String symbol);
}
