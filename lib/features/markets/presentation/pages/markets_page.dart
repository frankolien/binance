import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/coin_row_skeleton.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../markets_meta/domain/entities/coin_meta.dart';
import '../../domain/entities/ticker.dart';
import '../bloc/markets_bloc.dart';
import '../widgets/balance_hero.dart';
import '../widgets/markets_header.dart';
import '../widgets/markets_sub_tabs.dart';
import '../widgets/start_trading_promo.dart';
import '../widgets/ticker_row.dart';

@RoutePage()
class MarketsPage extends StatelessWidget {
  const MarketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MarketsBloc>(
      create: (_) =>
          getIt<MarketsBloc>()..add(const MarketsLoadRequested()),
      child: const _MarketsView(),
    );
  }
}

class _MarketsView extends StatefulWidget {
  const _MarketsView();

  @override
  State<_MarketsView> createState() => _MarketsViewState();
}

class _MarketsViewState extends State<_MarketsView> {
  MarketsTab _activeTab = MarketsTab.coin;
  MarketsSort _sort = MarketsSort.hot;
  bool _balanceHidden = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const MarketsHeader(),
            BalanceHero(
              value: '\$0.138354',
              hidden: _balanceHidden,
              onToggleVisibility: () =>
                  setState(() => _balanceHidden = !_balanceHidden),
              onAddFunds: () {},
            ),
            const StartTradingPromo(),
            MarketsSubTabs(
              activeTab: _activeTab,
              onTabChanged: (t) => setState(() => _activeTab = t),
            ),
            MarketsSortChips(
              sort: _sort,
              onChanged: (s) => setState(() => _sort = s),
            ),
            Expanded(
              child: BlocBuilder<MarketsBloc, MarketsState>(
                builder: (context, state) {
                  return switch (state) {
                    MarketsInitial() ||
                    MarketsLoading() =>
                      const _LoadingView(),
                    MarketsLoaded(:final tickers, :final meta) => _LoadedView(
                        tickers: tickers,
                        meta: meta,
                        tab: _activeTab,
                        sort: _sort,
                      ),
                    MarketsError(:final failure) => _ErrorView(
                        message: failure.message,
                        onRetry: () => context
                            .read<MarketsBloc>()
                            .add(const MarketsLoadRequested()),
                      ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return SkeletonGroup(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10,
        itemBuilder: (_, __) => const CoinRowSkeleton(),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.tickers,
    required this.meta,
    required this.tab,
    required this.sort,
  });

  final List<Ticker> tickers;
  final Map<String, CoinMeta> meta;
  final MarketsTab tab;
  final MarketsSort sort;

  @override
  Widget build(BuildContext context) {
    if (tab == MarketsTab.watchlist) {
      return const _EmptyWatchlist();
    }

    final coins = _aggregateCoins(tickers);
    final sorted = _applySort(coins, sort, meta);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<MarketsBloc>().add(const MarketsRefreshRequested());
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: sorted.length,
        separatorBuilder: (_, __) => const SizedBox(height: 0),
        itemBuilder: (rowContext, i) => TickerRow(
          ticker: sorted[i],
          meta: meta[sorted[i].baseAsset.toLowerCase()],
          onTap: () => rowContext.router.push(
            CoinDetailRoute(symbol: sorted[i].symbol),
          ),
        ),
      ),
    );
  }

  /// Per-base-asset aggregation: for each asset, prefer USDT pair, fall back
  /// to USDC, BUSD, FDUSD, then any quote.
  static List<Ticker> _aggregateCoins(List<Ticker> tickers) {
    const preferredQuotes = ['USDT', 'USDC', 'FDUSD', 'BUSD', 'TUSD'];
    final byBase = <String, Ticker>{};
    for (final t in tickers) {
      if (t.baseAsset.isEmpty) continue;
      final existing = byBase[t.baseAsset];
      if (existing == null) {
        byBase[t.baseAsset] = t;
        continue;
      }
      final newRank = preferredQuotes.indexOf(t.quoteAsset);
      final existingRank = preferredQuotes.indexOf(existing.quoteAsset);
      final newScore = newRank == -1 ? 999 : newRank;
      final existingScore = existingRank == -1 ? 999 : existingRank;
      if (newScore < existingScore) {
        byBase[t.baseAsset] = t;
      }
    }
    return byBase.values.toList(growable: false);
  }

  static List<Ticker> _applySort(
    List<Ticker> coins,
    MarketsSort sort,
    Map<String, CoinMeta> meta,
  ) {
    final list = [...coins];

    int rankOf(Ticker t) {
      final m = meta[t.baseAsset.toLowerCase()];
      // Coins not in CoinGecko's top list go to the bottom.
      return m?.marketCapRank ?? 999999;
    }

    switch (sort) {
      case MarketsSort.hot:
      case MarketsSort.marketCap:
        // Real ranking: lower rank number = higher position.
        list.sort((a, b) {
          final ra = rankOf(a);
          final rb = rankOf(b);
          if (ra != rb) return ra.compareTo(rb);
          // Tie-break by 24h volume.
          return b.quoteVolume.compareTo(a.quoteVolume);
        });
      case MarketsSort.price:
        list.sort((a, b) => b.lastPrice.compareTo(a.lastPrice));
      case MarketsSort.change24h:
        list.sort(
            (a, b) => b.priceChangePercent.compareTo(a.priceChangePercent));
    }
    return list;
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_outline,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              'No favorites yet',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
