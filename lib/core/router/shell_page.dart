import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/app_constants.dart';
import '../../features/settings/presentation/bloc/app_settings_cubit.dart';
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
              bottomNavigationBar: _BottomNav(
                tabsRouter: tabsRouter,
                isPro: isPro,
              ),
            );
          },
        );
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.tabsRouter, required this.isPro});

  final TabsRouter tabsRouter;
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    final items = isPro
        ? const [
            _NavItem(Icons.home_outlined, Icons.home, 'Home'),
            _NavItem(Icons.show_chart_outlined, Icons.show_chart, 'Markets'),
            _NavItem(Icons.swap_horiz_outlined, Icons.swap_horiz, 'Trade'),
            _NavItem(Icons.trending_up_outlined, Icons.trending_up, 'Futures'),
            _NavItem(
              Icons.account_balance_wallet_outlined,
              Icons.account_balance_wallet,
              'Assets',
            ),
          ]
        : const [
            _NavItem(Icons.show_chart_outlined, Icons.show_chart, 'Markets'),
            _NavItem(Icons.forum_outlined, Icons.forum, 'Square'),
            _NavItem(Icons.swap_horiz_outlined, Icons.swap_horiz, 'Trade'),
            _NavItem(Icons.explore_outlined, Icons.explore, 'Discover'),
            _NavItem(Icons.pie_chart_outline, Icons.pie_chart, 'Portfolio'),
          ];

    return NavigationBar(
      selectedIndex: tabsRouter.activeIndex,
      onDestinationSelected: tabsRouter.setActiveIndex,
      destinations: [
        for (final item in items)
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
