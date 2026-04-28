enum CoinTimeframe {
  hour,
  day,
  week,
  month,
  year;

  String get label => switch (this) {
        CoinTimeframe.hour => '1H',
        CoinTimeframe.day => '1D',
        CoinTimeframe.week => '1W',
        CoinTimeframe.month => '1M',
        CoinTimeframe.year => '1Y',
      };

  /// Binance kline interval for this timeframe.
  String get binanceInterval => switch (this) {
        CoinTimeframe.hour => '1m',
        CoinTimeframe.day => '15m',
        CoinTimeframe.week => '1h',
        CoinTimeframe.month => '4h',
        CoinTimeframe.year => '1d',
      };

  /// Number of candles to request to span the timeframe.
  int get candleLimit => switch (this) {
        CoinTimeframe.hour => 60,
        CoinTimeframe.day => 96,
        CoinTimeframe.week => 168,
        CoinTimeframe.month => 180,
        CoinTimeframe.year => 365,
      };
}
