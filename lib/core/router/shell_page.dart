import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../features/settings/presentation/bloc/app_settings_cubit.dart';
import '../constants/app_constants.dart';
import '../widgets/lite_bottom_nav.dart';
import 'app_router.dart';

@RoutePage()
class ShellPage extends StatelessWidget {
  const ShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      buildWhen: (p, c) => p.mode != c.mode,
      builder: (context, settings) {
        final isPro = settings.mode == AppMode.pro;
        final routes = isPro
            ? const [
                HomeRoute(),
                MarketsRoute(),
                TradeRoute(),
                FuturesRoute(),
                AssetsRoute(),
              ]
            : const [
                MarketsRoute(),
                SquareRoute(),
                TradeRoute(),
                DiscoverRoute(),
                PortfolioRoute(),
              ];

        return AutoTabsRouter(
          routes: routes,
          builder: (context, child) {
            final tabsRouter = AutoTabsRouter.of(context);
            return Scaffold(
              body: child,
              extendBody: !isPro,
              bottomNavigationBar: isPro
                  ? _ProBottomNav(tabsRouter: tabsRouter)
                  : _LiteBottomNavWrapper(tabsRouter: tabsRouter),
            );
          },
        );
      },
    );
  }
}

class _LiteBottomNavWrapper extends StatelessWidget {
  const _LiteBottomNavWrapper({required this.tabsRouter});

  final TabsRouter tabsRouter;

  @override
  Widget build(BuildContext context) {
    return LiteBottomNav(
      activeIndex: tabsRouter.activeIndex,
      items: [
        LiteBottomNavItem(
          icon: PhosphorIconsRegular.chartBar,
          activeIcon: PhosphorIconsFill.chartBar,
          label: 'Markets',
        ),
        LiteBottomNavItem(
          icon: PhosphorIconsRegular.chatCircleText,
          activeIcon: PhosphorIconsFill.chatCircleText,
          label: 'Square',
        ),
        // Center FAB takes index 2; LiteBottomNav skips rendering it.
        LiteBottomNavItem(
          icon: PhosphorIconsRegular.arrowsLeftRight,
          activeIcon: PhosphorIconsFill.arrowsLeftRight,
          label: 'Trade',
        ),
        LiteBottomNavItem(
          icon: PhosphorIconsRegular.compass,
          activeIcon: PhosphorIconsFill.compass,
          label: 'Discover',
        ),
        LiteBottomNavItem(
          icon: PhosphorIconsRegular.wallet,
          activeIcon: PhosphorIconsFill.wallet,
          label: 'Portfolio',
        ),
      ],
      onTabSelected: tabsRouter.setActiveIndex,
      onTradeTapped: () => tabsRouter.setActiveIndex(2),
    );
  }
}

class _ProBottomNav extends StatelessWidget {
  const _ProBottomNav({required this.tabsRouter});

  final TabsRouter tabsRouter;

  static final _items = [
    _NavItem(
        PhosphorIconsRegular.house, PhosphorIconsFill.house, 'Home'),
    _NavItem(PhosphorIconsRegular.chartBar, PhosphorIconsFill.chartBar,
        'Markets'),
    _NavItem(PhosphorIconsRegular.arrowsLeftRight,
        PhosphorIconsFill.arrowsLeftRight, 'Trade'),
    _NavItem(PhosphorIconsRegular.trendUp, PhosphorIconsFill.trendUp,
        'Futures'),
    _NavItem(
        PhosphorIconsRegular.wallet, PhosphorIconsFill.wallet, 'Assets'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: tabsRouter.activeIndex,
      onDestinationSelected: tabsRouter.setActiveIndex,
      destinations: [
        for (final item in _items)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: item.label,
          ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
