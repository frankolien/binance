part of 'coin_detail_bloc.dart';

class CoinDetailState extends Equatable {
  const CoinDetailState({
    required this.symbol,
    this.timeframe = CoinTimeframe.hour,
    this.ticker,
    this.klines = const [],
    this.about,
    this.tickerLoading = false,
    this.chartLoading = false,
    this.aboutLoading = false,
    this.tickerError,
    this.chartError,
    this.aboutError,
  });

  /// The Binance symbol being viewed, e.g. 'BTCUSDT'.
  final String symbol;

  final CoinTimeframe timeframe;

  /// Live-ish 24h ticker (price, % change, etc.).
  final Ticker? ticker;

  /// Candles for the active [timeframe] only.
  final List<Kline> klines;

  /// Static metadata (rank, supply, ATH, etc.). Null while loading or if the
  /// coin couldn't be matched to a CoinGecko entry.
  final CoinAbout? about;

  final bool tickerLoading;
  final bool chartLoading;
  final bool aboutLoading;

  final Failure? tickerError;
  final Failure? chartError;
  final Failure? aboutError;

  bool get hasTicker => ticker != null;
  bool get hasChart => klines.isNotEmpty;
  bool get hasAbout => about != null;

  CoinDetailState copyWith({
    CoinTimeframe? timeframe,
    Ticker? ticker,
    List<Kline>? klines,
    CoinAbout? about,
    bool? tickerLoading,
    bool? chartLoading,
    bool? aboutLoading,
    Failure? tickerError,
    Failure? chartError,
    Failure? aboutError,
    bool clearTickerError = false,
    bool clearChartError = false,
    bool clearAboutError = false,
  }) {
    return CoinDetailState(
      symbol: symbol,
      timeframe: timeframe ?? this.timeframe,
      ticker: ticker ?? this.ticker,
      klines: klines ?? this.klines,
      about: about ?? this.about,
      tickerLoading: tickerLoading ?? this.tickerLoading,
      chartLoading: chartLoading ?? this.chartLoading,
      aboutLoading: aboutLoading ?? this.aboutLoading,
      tickerError: clearTickerError ? null : (tickerError ?? this.tickerError),
      chartError: clearChartError ? null : (chartError ?? this.chartError),
      aboutError: clearAboutError ? null : (aboutError ?? this.aboutError),
    );
  }

  @override
  List<Object?> get props => [
        symbol,
        timeframe,
        ticker,
        klines,
        about,
        tickerLoading,
        chartLoading,
        aboutLoading,
        tickerError,
        chartError,
        aboutError,
      ];
}
