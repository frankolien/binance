part of 'coin_detail_bloc.dart';

sealed class CoinDetailEvent extends Equatable {
  const CoinDetailEvent();

  @override
  List<Object?> get props => [];
}

class CoinDetailLoadRequested extends CoinDetailEvent {
  const CoinDetailLoadRequested();
}

class CoinDetailTimeframeChanged extends CoinDetailEvent {
  const CoinDetailTimeframeChanged(this.timeframe);

  final CoinTimeframe timeframe;

  @override
  List<Object?> get props => [timeframe];
}
