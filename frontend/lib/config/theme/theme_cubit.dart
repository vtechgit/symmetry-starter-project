import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeDarkKey = 'theme_dark';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs)
      : super(_prefs.getBool(_kThemeDarkKey) ?? true
            ? ThemeMode.dark
            : ThemeMode.light);

  void toggleTheme() {
    final isDark = state == ThemeMode.dark;
    _prefs.setBool(_kThemeDarkKey, !isDark);
    emit(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}
