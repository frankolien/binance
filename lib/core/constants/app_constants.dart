class AppConstants {
  AppConstants._();

  static const String appName = 'Binance';

  static const String binanceRestBase = 'https://data-api.binance.vision';
  static const String binanceRestBaseMain = 'https://api.binance.com';
  static const String binanceWsBase = 'wss://data-stream.binance.vision';
  static const String binanceWsBaseMain = 'wss://stream.binance.com:9443';

  static const String coinGeckoRestBase = 'https://api.coingecko.com/api/v3';

  static const String cryptoCompareRestBase =
      'https://min-api.cryptocompare.com';

  static const Duration defaultTimeout = Duration(seconds: 15);
  static const Duration wsReconnectInitial = Duration(seconds: 1);
  static const Duration wsReconnectMax = Duration(seconds: 30);
}

enum AppMode { lite, pro }

enum ReportingCurrency { usd, btc, eur }
