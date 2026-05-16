import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/square_post.dart';

enum SquareCategory { discover, hot, news }

abstract class SquareRepository {
  /// Fetches posts for [category]. Pass [beforeUnixSeconds] to page older.
  Future<Either<Failure, List<SquarePost>>> getPosts({
    required SquareCategory category,
    int? beforeUnixSeconds,
  });
}
