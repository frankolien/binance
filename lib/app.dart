import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/bloc/app_settings_cubit.dart';

class BinanceApp extends StatefulWidget {
  const BinanceApp({super.key});

  @override
  State<BinanceApp> createState() => _BinanceAppState();
}

class _BinanceAppState extends State<BinanceApp> {
  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppSettingsCubit>.value(value: getIt<AppSettingsCubit>()),
      ],
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        buildWhen: (p, c) => p.themeMode != c.themeMode,
        builder: (context, settings) {
          return MaterialApp.router(
            title: 'Binance',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            routerConfig: _router.config(),
          );
        },
      ),
    );
  }
}
