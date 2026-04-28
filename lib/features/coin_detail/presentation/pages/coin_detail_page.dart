import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/coin_names.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../markets/domain/entities/ticker.dart';
import '../../domain/entities/kline.dart';
import '../bloc/coin_detail_bloc.dart';
import '../widgets/about_section.dart';
import '../widgets/balance_row.dart';
import '../widgets/buy_convert_bar.dart';
import '../widgets/price_line_chart.dart';
import '../widgets/timeframe_selector.dart';

@RoutePage()
class CoinDetailPage extends StatelessWidget {
  const CoinDetailPage({required this.symbol, super.key});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CoinDetailBloc>(
      create: (_) => getIt.get<CoinDetailBloc>(param1: symbol)
        ..add(const CoinDetailLoadRequested()),
      child: const _CoinDetailView(),
    );
  }
}

class _CoinDetailView extends StatefulWidget {
  const _CoinDetailView();

  @override
  State<_CoinDetailView> createState() => _CoinDetailViewState();
}

class _CoinDetailViewState extends State<_CoinDetailView> {
  final _scrollController = ScrollController();
  bool _showStickyHeader = false;

  static const _stickyThreshold = 120.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > _stickyThreshold;
    if (shouldShow != _showStickyHeader) {
      setState(() => _showStickyHeader = shouldShow);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      body: BlocBuilder<CoinDetailBloc, CoinDetailState>(
        builder: (context, state) {
          final ticker = state.ticker;
          final base = ticker?.baseAsset ?? _baseFromSymbol(state.symbol);
          final coinName = state.about?.name ?? coinNameFor(base);

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(
                  collapsed: _showStickyHeader,
                  baseAsset: base,
                  coinName: coinName,
                  ticker: ticker,
                ),
                Expanded(
                  child: _buildBody(context, state, base, coinName),
                ),
                const BuyConvertBar(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CoinDetailState state,
    String base,
    String coinName,
  ) {
    if (state.tickerLoading && state.ticker == null) {
      return Center(
        child: SizedBox(
          width: 64,
          height: 64,
          child: Lottie.asset(AppAssets.lottieLoadingYellow, repeat: true),
        ),
      );
    }

    if (state.tickerError != null && state.ticker == null) {
      return _ErrorView(
        message: state.tickerError!.message,
        onRetry: () => context
            .read<CoinDetailBloc>()
            .add(const CoinDetailLoadRequested()),
      );
    }

    final ticker = state.ticker;
    if (ticker == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      children: [
        _PriceBlock(
          ticker: ticker,
          baseAsset: base,
          coinName: coinName,
          klines: state.klines,
        ),
        const SizedBox(height: 16),
        _ChartArea(state: state, positive: _changePercent(state.klines, ticker) >= 0),
        const SizedBox(height: 8),
        TimeframeSelector(
          selected: state.timeframe,
          onChanged: (tf) => context
              .read<CoinDetailBloc>()
              .add(CoinDetailTimeframeChanged(tf)),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        BalanceRow(baseAsset: base),
        const Divider(height: 1),
        if (state.about != null)
          AboutSection(about: state.about!, tickerSymbol: base)
        else if (state.aboutLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (state.aboutError != null)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.aboutError!.message,
              style: const TextStyle(color: AppColors.lightTextTertiary),
            ),
          ),
        const SizedBox(height: 32),
      ],
    );
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

class _Header extends StatelessWidget {
  const _Header({
    required this.collapsed,
    required this.baseAsset,
    required this.coinName,
    required this.ticker,
  });

  final bool collapsed;
  final String baseAsset;
  final String coinName;
  final Ticker? ticker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 24),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: collapsed && ticker != null
                  ? _StickyTitle(
                      key: const ValueKey('sticky'),
                      baseAsset: baseAsset,
                      ticker: ticker!,
                      theme: theme,
                    )
                  : const SizedBox.shrink(key: ValueKey('blank')),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.star, color: AppColors.brandYellow, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _StickyTitle extends StatelessWidget {
  const _StickyTitle({
    required this.baseAsset,
    required this.ticker,
    required this.theme,
    super.key,
  });

  final String baseAsset;
  final Ticker ticker;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final positive = ticker.isPositive;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          baseAsset,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.lightTextTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              PriceFormatter.formatUsd(ticker.lastPrice),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              PriceFormatter.formatPercent(ticker.priceChangePercent),
              style: TextStyle(
                color: positive ? AppColors.buy : AppColors.sell,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.ticker,
    required this.baseAsset,
    required this.coinName,
  });

  final Ticker ticker;
  final String baseAsset;
  final String coinName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positive = ticker.isPositive;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                baseAsset,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                coinName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextTertiary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  PriceFormatter.formatUsd(ticker.lastPrice),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 36,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            PriceFormatter.formatPercent(ticker.priceChangePercent),
            style: TextStyle(
              color: positive ? AppColors.buy : AppColors.sell,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartArea extends StatelessWidget {
  const _ChartArea({required this.state, required this.positive});

  final CoinDetailState state;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    if (state.chartLoading && state.klines.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.chartError != null && state.klines.isEmpty) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.chartError!.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.lightTextTertiary),
            ),
          ),
        ),
      );
    }
    return PriceLineChart(klines: state.klines, positive: positive);
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
