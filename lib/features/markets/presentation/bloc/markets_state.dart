part of 'markets_bloc.dart';

sealed class MarketsState extends Equatable {
  const MarketsState();

  @override
  List<Object?> get props => [];
}

class MarketsInitial extends MarketsState {
  const MarketsInitial();
}

class MarketsLoading extends MarketsState {
  const MarketsLoading();
}

class MarketsLoaded extends MarketsState {
  const MarketsLoaded({
    required this.tickers,
    this.meta = const {},
  });

  final List<Ticker> tickers;
  final Map<String, CoinMeta> meta;

  @override
  List<Object?> get props => [tickers, meta];
}

class MarketsError extends MarketsState {
  const MarketsError(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
