import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/price_formatter.dart';
import '../../../../../core/widgets/coin_icon.dart';
import '../../../../../core/widgets/coin_row_skeleton.dart';
import '../../../../../core/widgets/skeleton.dart';
import '../../../../markets/domain/entities/ticker.dart';
import '../../../../markets/domain/repositories/markets_repository.dart';
import '../../../../markets_meta/domain/entities/coin_meta.dart';
import '../../../../markets_meta/domain/repositories/coin_meta_repository.dart';
import '../bloc/buy_flow_bloc.dart';

/// In-memory across the app session — survives reopening Buy. Resets on
/// app restart. Move to SharedPreferences when real persistence is needed.
final List<String> _searchHistory = ['ETH', 'SOL', 'BTC'];

class BuyChooseCryptoStep extends StatefulWidget {
  const BuyChooseCryptoStep({super.key});

  @override
  State<BuyChooseCryptoStep> createState() => _BuyChooseCryptoStepState();
}

class _BuyChooseCryptoStepState extends State<BuyChooseCryptoStep> {
  final _query = TextEditingController();
  late final Future<_PickerData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<_PickerData> _load() async {
    final tickersFuture = getIt<MarketsRepository>().getTickers();
    final metaFuture = getIt<CoinMetaRepository>().getTopCoinsBySymbol();

    final tickerEither = await tickersFuture;
    final metaEither = await metaFuture;

    final tickers = tickerEither.fold<List<Ticker>>((_) => const [], (l) => l);
    final meta = metaEither.fold<Map<String, CoinMeta>>(
      (_) => const {},
      (m) => m,
    );

    // Aggregate USDT-quoted tickers per base asset.
    final byBase = <String, Ticker>{};
    for (final t in tickers) {
      if (t.baseAsset.isEmpty || t.quoteAsset != 'USDT') continue;
      byBase[t.baseAsset] = t;
    }

    final entries = byBase.entries
        .where((e) => meta.containsKey(e.key.toLowerCase()))
        .map((e) => (ticker: e.value, meta: meta[e.key.toLowerCase()]!))
        .toList()
      ..sort((a, b) {
        final ra = a.meta.marketCapRank ?? 9999;
        final rb = b.meta.marketCapRank ?? 9999;
        return ra.compareTo(rb);
      });

    return _PickerData(entries.take(50).toList(growable: false));
  }

  void _pickAsset(String symbol) {
    if (!_searchHistory.contains(symbol)) {
      _searchHistory.insert(0, symbol);
      if (_searchHistory.length > 6) _searchHistory.removeLast();
    }
    context.read<BuyFlowBloc>().add(BuyAssetPicked(symbol));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _SearchField(controller: _query),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<_PickerData>(
                future: _future,
                builder: (_, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return SkeletonGroup(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 8,
                        itemBuilder: (_, __) => const CoinRowSkeleton(),
                      ),
                    );
                  }
                  final data = snap.data;
                  if (data == null) {
                    return const Center(child: Text('Could not load assets'));
                  }
                  final query = _query.text.trim().toUpperCase();
                  final filtered = query.isEmpty
                      ? data.entries
                      : data.entries.where((e) {
                          return e.ticker.baseAsset.contains(query) ||
                              e.meta.name.toUpperCase().contains(query);
                        }).toList();
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      if (query.isEmpty && _searchHistory.isNotEmpty) ...[
                        _HistorySection(
                          history: _searchHistory,
                          onTap: _pickAsset,
                          onClear: () =>
                              setState(() => _searchHistory.clear()),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          query.isEmpty ? 'Top Search' : 'Results',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      for (final e in filtered)
                        _CoinRow(
                          ticker: e.ticker,
                          meta: e.meta,
                          onTap: () => _pickAsset(e.ticker.baseAsset),
                        ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerData {
  _PickerData(this.entries);
  final List<({Ticker ticker, CoinMeta meta})> entries;
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.lightSurfaceAlt,
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search, size: 22),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.history,
    required this.onTap,
    required this.onClear,
  });

  final List<String> history;
  final void Function(String) onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Search History', style: theme.textTheme.titleMedium),
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.lightTextTertiary),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in history)
              GestureDetector(
                onTap: () => onTap(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightSurfaceAlt,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextPrimary,
                      )),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CoinRow extends StatelessWidget {
  const _CoinRow({
    required this.ticker,
    required this.meta,
    required this.onTap,
  });

  final Ticker ticker;
  final CoinMeta meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CoinIcon(
              symbol: ticker.baseAsset,
              imageUrl: meta.imageUrl,
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meta.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600)),
                  Text(ticker.baseAsset, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Text(
              PriceFormatter.formatUsd(ticker.lastPrice),
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
