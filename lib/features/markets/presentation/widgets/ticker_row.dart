import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/coin_names.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/coin_icon.dart';
import '../../../markets_meta/domain/entities/coin_meta.dart';
import '../../domain/entities/ticker.dart';

class TickerRow extends StatelessWidget {
  const TickerRow({
    required this.ticker,
    this.meta,
    this.onTap,
    super.key,
  });

  final Ticker ticker;
  final CoinMeta? meta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positive = ticker.isPositive;
    final changeColor = positive ? AppColors.buy : AppColors.sell;

    // Prefer CoinGecko name (e.g. "Bitcoin"); fall back to local catalog;
    // fall back to ticker.
    final coinName = meta?.name ?? coinNameFor(ticker.baseAsset);
    final imageUrl = meta?.imageUrl;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            CoinIcon(
              symbol: ticker.baseAsset,
              imageUrl: imageUrl,
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coinName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ticker.baseAsset,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  PriceFormatter.formatPercent(ticker.priceChangePercent),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  PriceFormatter.formatUsd(ticker.lastPrice),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
