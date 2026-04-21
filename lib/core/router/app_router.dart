import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../features/coin_detail/presentation/pages/coin_detail_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/tab_stub_pages.dart';
import '../../features/markets/presentation/pages/markets_page.dart';
import 'shell_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: ShellRoute.page,
          path: '/',
          initial: true,
          children: [
            AutoRoute(page: HomeRoute.page, path: 'home'),
            AutoRoute(page: MarketsRoute.page, path: 'markets'),
            AutoRoute(page: TradeRoute.page, path: 'trade'),
            AutoRoute(page: FuturesRoute.page, path: 'futures'),
            AutoRoute(page: AssetsRoute.page, path: 'assets'),
            AutoRoute(page: SquareRoute.page, path: 'square'),
            AutoRoute(page: DiscoverRoute.page, path: 'discover'),
            AutoRoute(page: PortfolioRoute.page, path: 'portfolio'),
          ],
        ),
        AutoRoute(page: CoinDetailRoute.page, path: '/coin/:symbol'),
      ];
}
