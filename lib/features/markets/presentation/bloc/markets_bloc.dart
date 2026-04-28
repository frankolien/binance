import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../markets_meta/domain/entities/coin_meta.dart';
import '../../../markets_meta/domain/repositories/coin_meta_repository.dart';
import '../../domain/entities/ticker.dart';
import '../../domain/repositories/markets_repository.dart';

part 'markets_event.dart';
part 'markets_state.dart';

class MarketsBloc extends Bloc<MarketsEvent, MarketsState> {
  MarketsBloc(this._repository, this._metaRepository)
      : super(const MarketsInitial()) {
    on<MarketsLoadRequested>(_onLoadRequested);
    on<MarketsRefreshRequested>(_onRefreshRequested);
  }

  final MarketsRepository _repository;
  final CoinMetaRepository _metaRepository;

  Future<void> _onLoadRequested(
    MarketsLoadRequested event,
    Emitter<MarketsState> emit,
  ) async {
    emit(const MarketsLoading());
    await _fetchAndEmit(emit);
  }

  Future<void> _onRefreshRequested(
    MarketsRefreshRequested event,
    Emitter<MarketsState> emit,
  ) async {
    await _fetchAndEmit(emit);
  }

  Future<void> _fetchAndEmit(Emitter<MarketsState> emit) async {
    // Fire both calls in parallel — meta is enrichment, not blocking.
    final tickerFuture = _repository.getTickers();
    final metaFuture = _metaRepository.getTopCoinsBySymbol();

    final tickerResult = await tickerFuture;
    final metaResult = await metaFuture;

    final tickers = tickerResult.fold<List<Ticker>?>(
      (failure) {
        emit(MarketsError(failure));
        return null;
      },
      (list) => list,
    );
    if (tickers == null) return;

    final meta = metaResult.fold<Map<String, CoinMeta>>(
      (_) => const {},
      (m) => m,
    );

    emit(MarketsLoaded(tickers: tickers, meta: meta));
  }
}
