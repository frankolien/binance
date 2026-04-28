import 'package:equatable/equatable.dart';

class CoinMeta extends Equatable {
  const CoinMeta({
    required this.id,
    required this.symbol,
    required this.name,
    required this.marketCapRank,
    required this.imageUrl,
  });

  final String id;
  final String symbol; // lowercase, e.g. 'btc'
  final String name; // e.g. 'Bitcoin'
  final int? marketCapRank;
  final String imageUrl;

  @override
  List<Object?> get props => [id, symbol, name, marketCapRank, imageUrl];
}
