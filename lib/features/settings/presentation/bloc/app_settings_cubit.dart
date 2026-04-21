import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';

class AppSettingsState extends Equatable {
  const AppSettingsState({
    this.mode = AppMode.lite,
    this.themeMode = ThemeMode.system,
    this.reportingCurrency = ReportingCurrency.usd,
  });

  final AppMode mode;
  final ThemeMode themeMode;
  final ReportingCurrency reportingCurrency;

  AppSettingsState copyWith({
    AppMode? mode,
    ThemeMode? themeMode,
    ReportingCurrency? reportingCurrency,
  }) {
    return AppSettingsState(
      mode: mode ?? this.mode,
      themeMode: themeMode ?? this.themeMode,
      reportingCurrency: reportingCurrency ?? this.reportingCurrency,
    );
  }

  @override
  List<Object?> get props => [mode, themeMode, reportingCurrency];
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(const AppSettingsState());

  void setMode(AppMode mode) {
    final defaultCurrency =
        mode == AppMode.pro ? ReportingCurrency.btc : ReportingCurrency.usd;
    emit(state.copyWith(mode: mode, reportingCurrency: defaultCurrency));
  }

  void setThemeMode(ThemeMode mode) => emit(state.copyWith(themeMode: mode));

  void setReportingCurrency(ReportingCurrency c) =>
      emit(state.copyWith(reportingCurrency: c));
}
