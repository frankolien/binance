import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/placeholder_page.dart';

// Lite stubs
@RoutePage()
class TradePage extends StatelessWidget {
  const TradePage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(title: 'Trade');
}

@RoutePage()
class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const PlaceholderPage(title: 'Discover');
}

@RoutePage()
class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const PlaceholderPage(title: 'Portfolio');
}

// Pro stubs
@RoutePage()
class FuturesPage extends StatelessWidget {
  const FuturesPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const PlaceholderPage(title: 'Futures');
}

@RoutePage()
class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key});
  @override
  Widget build(BuildContext context) => const PlaceholderPage(title: 'Assets');
}
