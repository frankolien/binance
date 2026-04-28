import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class CoinAbout extends Equatable {
  const CoinAbout({
    required this.id,
    required this.symbol,
    required this.name,
    this.marketCapRank,
    this.marketCapUsd,
    this.circulatingSupply,
    this.maxSupply,
    this.totalSupply,
    this.issuePriceUsd,
    this.issueDate,
    this.allTimeHighUsd,
    this.allTimeHighDate,
    this.allTimeLowUsd,
    this.allTimeLowDate,
    this.websiteUrl,
    this.blockExplorerUrl,
    this.introduction,
  });

  final String id;
  final String symbol;
  final String name;
  final int? marketCapRank;
  final Decimal? marketCapUsd;
  final Decimal? circulatingSupply;
  final Decimal? maxSupply;
  final Decimal? totalSupply;
  final Decimal? issuePriceUsd;
  final DateTime? issueDate;
  final Decimal? allTimeHighUsd;
  final DateTime? allTimeHighDate;
  final Decimal? allTimeLowUsd;
  final DateTime? allTimeLowDate;
  final String? websiteUrl;
  final String? blockExplorerUrl;
  final String? introduction;

  @override
  List<Object?> get props => [
        id,
        symbol,
        name,
        marketCapRank,
        marketCapUsd,
        circulatingSupply,
        maxSupply,
        totalSupply,
        issuePriceUsd,
        issueDate,
        allTimeHighUsd,
        allTimeHighDate,
        allTimeLowUsd,
        allTimeLowDate,
        websiteUrl,
        blockExplorerUrl,
        introduction,
      ];
}
