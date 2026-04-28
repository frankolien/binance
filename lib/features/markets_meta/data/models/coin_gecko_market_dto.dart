import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/coin_meta.dart';

part 'coin_gecko_market_dto.g.dart';

@JsonSerializable(createToJson: false)
class CoinGeckoMarketDto {
  const CoinGeckoMarketDto({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    this.marketCapRank,
  });

  factory CoinGeckoMarketDto.fromJson(Map<String, dynamic> json) =>
      _$CoinGeckoMarketDtoFromJson(json);

  final String id;
  final String symbol;
  final String name;
  final String image;
  @JsonKey(name: 'market_cap_rank')
  final int? marketCapRank;

  CoinMeta toEntity() => CoinMeta(
        id: id,
        symbol: symbol.toLowerCase(),
        name: name,
        marketCapRank: marketCapRank,
        imageUrl: image,
      );
}
