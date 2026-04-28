import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CoinIcon extends StatelessWidget {
  const CoinIcon({
    required this.symbol,
    this.imageUrl,
    this.size = 36,
    super.key,
  });

  final String symbol;
  final String? imageUrl;
  final double size;

  static String _coinCapUrlFor(String symbol) =>
      'https://assets.coincap.io/assets/icons/${symbol.toLowerCase()}@2x.png';

  @override
  Widget build(BuildContext context) {
    // Prefer CoinGecko-supplied image (provided via meta); otherwise use the
    // CoinCap CDN fallback keyed by ticker symbol.
    final url = imageUrl ?? _coinCapUrlFor(symbol);

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, __) => _Fallback(symbol: symbol, size: size),
        errorWidget: (_, __, ___) => _Fallback(symbol: symbol, size: size),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.symbol, required this.size});

  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.outline.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        symbol.isEmpty ? '?' : symbol.characters.first.toUpperCase(),
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}
