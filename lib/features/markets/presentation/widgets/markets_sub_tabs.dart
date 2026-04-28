import 'package:flutter/material.dart';

enum MarketsTab { watchlist, coin }

enum MarketsSort { hot, marketCap, price, change24h }

class MarketsSubTabs extends StatelessWidget {
  const MarketsSubTabs({
    required this.activeTab,
    required this.onTabChanged,
    super.key,
  });

  final MarketsTab activeTab;
  final ValueChanged<MarketsTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          _SubTab(
            label: 'Watchlist',
            active: activeTab == MarketsTab.watchlist,
            onTap: () => onTabChanged(MarketsTab.watchlist),
            theme: theme,
          ),
          const SizedBox(width: 18),
          _SubTab(
            label: 'Coin',
            active: activeTab == MarketsTab.coin,
            onTap: () => onTabChanged(MarketsTab.coin),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _SubTab extends StatelessWidget {
  const _SubTab({
    required this.label,
    required this.active,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: active ? 22 : 18,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class MarketsSortChips extends StatelessWidget {
  const MarketsSortChips({
    required this.sort,
    required this.onChanged,
    super.key,
  });

  final MarketsSort sort;
  final ValueChanged<MarketsSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _Chip(
            label: 'Hot',
            active: sort == MarketsSort.hot,
            onTap: () => onChanged(MarketsSort.hot),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Market Cap',
            active: sort == MarketsSort.marketCap,
            onTap: () => onChanged(MarketsSort.marketCap),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Price',
            active: sort == MarketsSort.price,
            onTap: () => onChanged(MarketsSort.price),
            sortable: true,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: '24h Change',
            active: sort == MarketsSort.change24h,
            onTap: () => onChanged(MarketsSort.change24h),
            sortable: true,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
    this.sortable = false,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool sortable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = active
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            color: fg,
          ),
        ),
        if (sortable) ...[
          const SizedBox(width: 4),
          Icon(Icons.unfold_more, size: 12, color: fg),
        ],
      ],
    );

    if (active) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                theme.colorScheme.onSurface.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: child,
      ),
    );
  }
}
