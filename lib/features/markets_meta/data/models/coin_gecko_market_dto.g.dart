// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_gecko_market_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinGeckoMarketDto _$CoinGeckoMarketDtoFromJson(Map<String, dynamic> json) =>
    CoinGeckoMarketDto(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      marketCapRank: (json['market_cap_rank'] as num?)?.toInt(),
    );
