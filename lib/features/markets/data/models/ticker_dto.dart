import 'package:decimal/decimal.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/ticker.dart';

part 'ticker_dto.g.dart';

@JsonSerializable(createToJson: false)
class TickerDto {
  const TickerDto({
    required this.symbol,
    required this.lastPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.quoteVolume,
  });

  factory TickerDto.fromJson(Map<String, dynamic> json) =>
      _$TickerDtoFromJson(json);

  final String symbol;
  final String lastPrice;
  final String priceChange;
  final String priceChangePercent;
  final String highPrice;
  final String lowPrice;
  final String volume;
  final String quoteVolume;

  Ticker toEntity() {
    final (base, quote) = _splitSymbol(symbol);
    return Ticker(
      symbol: symbol,
      baseAsset: base,
      quoteAsset: quote,
      lastPrice: Decimal.parse(lastPrice),
      priceChange: Decimal.parse(priceChange),
      priceChangePercent: double.parse(priceChangePercent),
      highPrice: Decimal.parse(highPrice),
      lowPrice: Decimal.parse(lowPrice),
      volume: Decimal.parse(volume),
      quoteVolume: Decimal.parse(quoteVolume),
    );
  }
}

const _knownQuoteAssets = <String>[
  'USDT',
  'USDC',
  'FDUSD',
  'TUSD',
  'BUSD',
  'BTC',
  'ETH',
  'BNB',
  'EUR',
  'TRY',
  'USD',
];

(String, String) _splitSymbol(String symbol) {
  for (final quote in _knownQuoteAssets) {
    if (symbol.endsWith(quote) && symbol.length > quote.length) {
      return (symbol.substring(0, symbol.length - quote.length), quote);
    }
  }
  return (symbol, '');
}
