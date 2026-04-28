import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constants/app_assets.dart';

class LiteBottomNavItem {
  const LiteBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class LiteBottomNav extends StatelessWidget {
  const LiteBottomNav({
    required this.activeIndex,
    required this.items,
    required this.onTabSelected,
    required this.onTradeTapped,
    this.tradeIndex = 2,
    super.key,
  });

  final int activeIndex;
  final List<LiteBottomNavItem> items;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onTradeTapped;
  final int tradeIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom nav bar background.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: i == 2
                          // Spot reserved for the center FAB; keep
                          // an empty area for tap to fall through.
                          ? const SizedBox.shrink()
                          : _NavTab(
                              item: items[i],
                              active: activeIndex == i,
                              onTap: () => onTabSelected(i),
                            ),
                    ),
                ],
              ),
            ),
          ),
          // Center FAB (Trade).
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Center(
              child: _TradeFab(
                onTap: onTradeTapped,
                active: activeIndex == tradeIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final LiteBottomNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = active
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(active ? item.activeIcon : item.icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TradeFab extends StatefulWidget {
  const _TradeFab({required this.onTap, required this.active});

  final VoidCallback onTap;
  final bool active;

  @override
  State<_TradeFab> createState() => _TradeFabState();
}

class _TradeFabState extends State<_TradeFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant _TradeFab old) {
    super.didUpdateWidget(old);
    if (_ready && old.active != widget.active) {
      if (widget.active) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Lottie.asset(
              theme.brightness == Brightness.dark
                  ? AppAssets.lottieLiteTradeFabDark
                  : AppAssets.lottieLiteTradeFab,
              controller: _controller,
              fit: BoxFit.contain,
              onLoaded: (composition) {
                _controller.duration = composition.duration;
                // Rest on the inactive frame at first paint, then sync to
                // current active state.
                _controller.value = widget.active ? 1.0 : 0.0;
                _ready = true;
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Trade',
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
