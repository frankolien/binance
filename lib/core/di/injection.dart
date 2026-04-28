import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/coin_detail/data/datasources/coin_about_remote_datasource.dart';
import '../../features/coin_detail/data/datasources/klines_remote_datasource.dart';
import '../../features/coin_detail/data/repositories/coin_detail_repository_impl.dart';
import '../../features/coin_detail/domain/repositories/coin_detail_repository.dart';
import '../../features/coin_detail/presentation/bloc/coin_detail_bloc.dart';
import '../../features/markets/data/datasources/markets_remote_datasource.dart';
import '../../features/markets/data/repositories/markets_repository_impl.dart';
import '../../features/markets/domain/repositories/markets_repository.dart';
import '../../features/markets/presentation/bloc/markets_bloc.dart';
import '../../features/markets_meta/data/datasources/coin_gecko_remote_datasource.dart';
import '../../features/markets_meta/data/repositories/coin_meta_repository_impl.dart';
import '../../features/markets_meta/domain/repositories/coin_meta_repository.dart';
import '../../features/settings/presentation/bloc/app_settings_cubit.dart';
import '../constants/app_constants.dart';

final getIt = GetIt.instance;

const _binanceDioName = 'binanceDio';
const _coinGeckoDioName = 'coinGeckoDio';

Future<void> configureDependencies() async {
  // ────── HTTP clients ──────
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: AppConstants.binanceRestBase,
        connectTimeout: AppConstants.defaultTimeout,
        receiveTimeout: AppConstants.defaultTimeout,
        headers: {'Accept': 'application/json'},
      ),
    ),
    instanceName: _binanceDioName,
  );

  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: AppConstants.coinGeckoRestBase,
        connectTimeout: AppConstants.defaultTimeout,
        receiveTimeout: AppConstants.defaultTimeout,
        headers: {'Accept': 'application/json'},
      ),
    ),
    instanceName: _coinGeckoDioName,
  );

  // ────── Markets feature ──────
  getIt.registerLazySingleton<MarketsRemoteDataSource>(
    () => MarketsRemoteDataSourceImpl(getIt<Dio>(instanceName: _binanceDioName)),
  );
  getIt.registerLazySingleton<MarketsRepository>(
    () => MarketsRepositoryImpl(getIt<MarketsRemoteDataSource>()),
  );

  // ────── Markets meta (CoinGecko) ──────
  getIt.registerLazySingleton<CoinGeckoRemoteDataSource>(
    () => CoinGeckoRemoteDataSourceImpl(
      getIt<Dio>(instanceName: _coinGeckoDioName),
    ),
  );
  getIt.registerLazySingleton<CoinMetaRepository>(
    () => CoinMetaRepositoryImpl(getIt<CoinGeckoRemoteDataSource>()),
  );

  // ────── Coin detail feature ──────
  getIt.registerLazySingleton<KlinesRemoteDataSource>(
    () => KlinesRemoteDataSourceImpl(getIt<Dio>(instanceName: _binanceDioName)),
  );
  getIt.registerLazySingleton<CoinAboutRemoteDataSource>(
    () => CoinAboutRemoteDataSourceImpl(
      getIt<Dio>(instanceName: _coinGeckoDioName),
    ),
  );
  getIt.registerLazySingleton<CoinDetailRepository>(
    () => CoinDetailRepositoryImpl(
      klines: getIt<KlinesRemoteDataSource>(),
      about: getIt<CoinAboutRemoteDataSource>(),
      meta: getIt<CoinMetaRepository>(),
    ),
  );

  // ────── Blocs ──────
  getIt.registerFactory<MarketsBloc>(
    () => MarketsBloc(
      getIt<MarketsRepository>(),
      getIt<CoinMetaRepository>(),
    ),
  );

  getIt.registerFactoryParam<CoinDetailBloc, String, void>(
    (symbol, _) => CoinDetailBloc(
      symbol: symbol,
      marketsRepository: getIt<MarketsRepository>(),
      detailRepository: getIt<CoinDetailRepository>(),
    ),
  );

  // ────── App-wide settings ──────
  getIt.registerLazySingleton<AppSettingsCubit>(() => AppSettingsCubit());
}
