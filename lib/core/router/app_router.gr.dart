// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AssetsPage]
class AssetsRoute extends PageRouteInfo<void> {
  const AssetsRoute({List<PageRouteInfo>? children})
    : super(AssetsRoute.name, initialChildren: children);

  static const String name = 'AssetsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AssetsPage();
    },
  );
}

/// generated route for
/// [CoinDetailPage]
class CoinDetailRoute extends PageRouteInfo<CoinDetailRouteArgs> {
  CoinDetailRoute({
    required String symbol,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
         CoinDetailRoute.name,
         args: CoinDetailRouteArgs(symbol: symbol, key: key),
         initialChildren: children,
       );

  static const String name = 'CoinDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CoinDetailRouteArgs>();
      return CoinDetailPage(symbol: args.symbol, key: args.key);
    },
  );
}

class CoinDetailRouteArgs {
  const CoinDetailRouteArgs({required this.symbol, this.key});

  final String symbol;

  final Key? key;

  @override
  String toString() {
    return 'CoinDetailRouteArgs{symbol: $symbol, key: $key}';
  }
}

/// generated route for
/// [DiscoverPage]
class DiscoverRoute extends PageRouteInfo<void> {
  const DiscoverRoute({List<PageRouteInfo>? children})
    : super(DiscoverRoute.name, initialChildren: children);

  static const String name = 'DiscoverRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DiscoverPage();
    },
  );
}

/// generated route for
/// [FuturesPage]
class FuturesRoute extends PageRouteInfo<void> {
  const FuturesRoute({List<PageRouteInfo>? children})
    : super(FuturesRoute.name, initialChildren: children);

  static const String name = 'FuturesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FuturesPage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [MarketsPage]
class MarketsRoute extends PageRouteInfo<void> {
  const MarketsRoute({List<PageRouteInfo>? children})
    : super(MarketsRoute.name, initialChildren: children);

  static const String name = 'MarketsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MarketsPage();
    },
  );
}

/// generated route for
/// [PortfolioPage]
class PortfolioRoute extends PageRouteInfo<void> {
  const PortfolioRoute({List<PageRouteInfo>? children})
    : super(PortfolioRoute.name, initialChildren: children);

  static const String name = 'PortfolioRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PortfolioPage();
    },
  );
}

/// generated route for
/// [ShellPage]
class ShellRoute extends PageRouteInfo<void> {
  const ShellRoute({List<PageRouteInfo>? children})
    : super(ShellRoute.name, initialChildren: children);

  static const String name = 'ShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ShellPage();
    },
  );
}

/// generated route for
/// [SquarePage]
class SquareRoute extends PageRouteInfo<void> {
  const SquareRoute({List<PageRouteInfo>? children})
    : super(SquareRoute.name, initialChildren: children);

  static const String name = 'SquareRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SquarePage();
    },
  );
}

/// generated route for
/// [TradePage]
class TradeRoute extends PageRouteInfo<void> {
  const TradeRoute({List<PageRouteInfo>? children})
    : super(TradeRoute.name, initialChildren: children);

  static const String name = 'TradeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TradePage();
    },
  );
}
