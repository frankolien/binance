part of 'square_bloc.dart';

sealed class SquareState extends Equatable {
  const SquareState();

  @override
  List<Object?> get props => [];
}

class SquareInitial extends SquareState {
  const SquareInitial();
}

class SquareLoading extends SquareState {
  const SquareLoading();
}

class SquareLoaded extends SquareState {
  const SquareLoaded({
    required this.posts,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
  });

  final List<SquarePost> posts;
  final bool isLoadingMore;
  final bool hasReachedEnd;

  SquareLoaded copyWith({
    List<SquarePost>? posts,
    bool? isLoadingMore,
    bool? hasReachedEnd,
  }) {
    return SquareLoaded(
      posts: posts ?? this.posts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }

  @override
  List<Object?> get props => [posts, isLoadingMore, hasReachedEnd];
}

class SquareError extends SquareState {
  const SquareError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
