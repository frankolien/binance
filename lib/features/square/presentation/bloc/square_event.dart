part of 'square_bloc.dart';

sealed class SquareEvent extends Equatable {
  const SquareEvent();

  @override
  List<Object?> get props => [];
}

class SquareLoadRequested extends SquareEvent {
  const SquareLoadRequested();
}

class SquareRefreshRequested extends SquareEvent {
  const SquareRefreshRequested();
}

class SquareLoadMore extends SquareEvent {
  const SquareLoadMore();
}
