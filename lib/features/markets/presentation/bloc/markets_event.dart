part of 'markets_bloc.dart';

sealed class MarketsEvent extends Equatable {
  const MarketsEvent();

  @override
  List<Object?> get props => [];
}

class MarketsLoadRequested extends MarketsEvent {
  const MarketsLoadRequested();
}

class MarketsRefreshRequested extends MarketsEvent {
  const MarketsRefreshRequested();
}
