import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class CoinDetailPage extends StatelessWidget {
  const CoinDetailPage({required this.symbol, super.key});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(symbol)),
      body: Center(child: Text('Coin detail — $symbol')),
    );
  }
}
