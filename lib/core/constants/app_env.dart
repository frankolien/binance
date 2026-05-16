import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime accessor for values in the bundled `.env` file.
/// Must be loaded once in `main()` before any read: `await dotenv.load();`.
class AppEnv {
  AppEnv._();

  static String get cryptoCompareApiKey =>
      dotenv.maybeGet('CRYPTOCOMPARE_API_KEY') ?? '';
}
