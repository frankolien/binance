import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/square_post.dart';
import '../../domain/repositories/square_repository.dart';

part 'square_event.dart';
part 'square_state.dart';

class SquareBloc extends Bloc<SquareEvent, SquareState> {
  SquareBloc({required this.category, required SquareRepository repository})
      : _repository = repository,
        super(const SquareInitial()) {
    on<SquareLoadRequested>(_onLoad);
    on<SquareRefreshRequested>(_onRefresh);
    on<SquareLoadMore>(_onLoadMore);
  }

  final SquareCategory category;
  final SquareRepository _repository;

  Future<void> _onLoad(
    SquareLoadRequested event,
    Emitter<SquareState> emit,
  ) async {
    emit(const SquareLoading());
    final result = await _repository.getPosts(category: category);
    result.fold(
      (failure) => emit(SquareError(failure)),
      (posts) => emit(SquareLoaded(posts: posts)),
    );
  }

  Future<void> _onRefresh(
    SquareRefreshRequested event,
    Emitter<SquareState> emit,
  ) async {
    final result = await _repository.getPosts(category: category);
    result.fold(
      (failure) => emit(SquareError(failure)),
      (posts) => emit(SquareLoaded(posts: posts)),
    );
  }

  Future<void> _onLoadMore(
    SquareLoadMore event,
    Emitter<SquareState> emit,
  ) async {
    final current = state;
    if (current is! SquareLoaded || current.hasReachedEnd) return;
    if (current.posts.isEmpty) return;

    emit(current.copyWith(isLoadingMore: true));
    final oldest = current.posts.last.publishedAt;
    final result = await _repository.getPosts(
      category: category,
      beforeUnixSeconds: oldest.toUtc().millisecondsSinceEpoch ~/ 1000,
    );
    result.fold(
      (failure) => emit(current.copyWith(isLoadingMore: false)),
      (more) => emit(current.copyWith(
        posts: [...current.posts, ...more],
        isLoadingMore: false,
        hasReachedEnd: more.isEmpty,
      )),
    );
  }
}
