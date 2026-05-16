import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/square_post.dart';
import '../../domain/repositories/square_repository.dart';
import '../datasources/square_remote_datasource.dart';

class SquareRepositoryImpl implements SquareRepository {
  SquareRepositoryImpl(this._remote);

  final SquareRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<SquarePost>>> getPosts({
    required SquareCategory category,
    int? beforeUnixSeconds,
  }) async {
    try {
      final dtos = await _remote.fetchPosts(
        category: category,
        beforeUnixSeconds: beforeUnixSeconds,
      );
      var posts = dtos.map((d) => d.toEntity()).toList(growable: false);

      // Hot == We have no engagement signal,
     
      if (category == SquareCategory.hot) {
        posts = [...posts]
          ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      }

      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
