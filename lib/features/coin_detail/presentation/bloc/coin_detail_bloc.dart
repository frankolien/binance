import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../markets/domain/entities/ticker.dart';
import '../../../markets/domain/repositories/markets_repository.dart';
import '../../domain/entities/coin_about.dart';
import '../../domain/entities/coin_timeframe.dart';
import '../../domain/entities/kline.dart';
import '../../domain/repositories/coin_detail_repository.dart';

part 'coin_detail_event.dart';
part 'coin_detail_state.dart';

class CoinDetailBloc extends Bloc<CoinDetailEvent, CoinDetailState> {
  CoinDetailBloc({
    required String symbol,
    required MarketsRepository marketsRepository,
    required CoinDetailRepository detailRepository,
  })  : _markets = marketsRepository,
        _detail = detailRepository,
        super(CoinDetailState(symbol: symbol)) {
    on<CoinDetailLoadRequested>(_onLoadRequested);
    on<CoinDetailTimeframeChanged>(_onTimeframeChanged);
  }

  final MarketsRepository _markets;
  final CoinDetailRepository _detail;

  Future<void> _onLoadRequested(
    CoinDetailLoadRequested event,
    Emitter<CoinDetailState> emit,
  ) async {
    emit(state.copyWith(
      tickerLoading: true,
      chartLoading: true,
      aboutLoading: true,
      clearTickerError: true,
      clearChartError: true,
      clearAboutError: true,
    ));

    final tickerFuture = _markets.getTicker(state.symbol);
    final klinesFuture = _detail.getKlines(
      symbol: state.symbol,
      timeframe: state.timeframe,
    );
    // baseAsset isn't known yet; resolve via prefix-strip on common quotes.
    final base = _baseFromSymbol(state.symbol);
    final aboutFuture = _detail.getAbout(base);

    final tickerResult = await tickerFuture;
    final klineResult = await klinesFuture;
    final aboutResult = await aboutFuture;

    var next = state;

    next = tickerResult.fold(
      (f) => next.copyWith(tickerLoading: false, tickerError: f),
      (t) => next.copyWith(tickerLoading: false, ticker: t),
    );

    next = klineResult.fold(
      (f) => next.copyWith(chartLoading: false, chartError: f),
      (k) => next.copyWith(chartLoading: false, klines: k),
    );

    next = aboutResult.fold(
      (f) => next.copyWith(aboutLoading: false, aboutError: f),
      (a) => next.copyWith(aboutLoading: false, about: a),
    );

    emit(next);
  }

  Future<void> _onTimeframeChanged(
    CoinDetailTimeframeChanged event,
    Emitter<CoinDetailState> emit,
  ) async {
    if (event.timeframe == state.timeframe) return;

    emit(state.copyWith(
      timeframe: event.timeframe,
      chartLoading: true,
      clearChartError: true,
    ));

    final result = await _detail.getKlines(
      symbol: state.symbol,
      timeframe: event.timeframe,
    );

    emit(result.fold(
      (f) => state.copyWith(chartLoading: false, chartError: f),
      (k) => state.copyWith(chartLoading: false, klines: k),
    ));
  }

  static String _baseFromSymbol(String symbol) {
    const quotes = [
      'USDT', 'USDC', 'FDUSD', 'TUSD', 'BUSD',
      'BTC', 'ETH', 'BNB', 'EUR', 'TRY', 'USD',
    ];
    for (final q in quotes) {
      if (symbol.endsWith(q) && symbol.length > q.length) {
        return symbol.substring(0, symbol.length - q.length);
      }
    }
    return symbol;
  }
}
