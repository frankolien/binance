import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class Ticker extends Equatable {
  const Ticker({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.lastPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.quoteVolume,
  });

  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final Decimal lastPrice;
  final Decimal priceChange;
  final double priceChangePercent;
  final Decimal highPrice;
  final Decimal lowPrice;
  final Decimal volume;
  final Decimal quoteVolume;

  bool get isPositive => priceChangePercent >= 0;

  @override
  List<Object?> get props => [
        symbol,
        baseAsset,
        quoteAsset,
        lastPrice,
        priceChange,
        priceChangePercent,
        highPrice,
        lowPrice,
        volume,
        quoteVolume,
      ];
}
