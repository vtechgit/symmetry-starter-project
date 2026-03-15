import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ThemeCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    cubit = ThemeCubit(prefs);
  });

  tearDown(() {
    cubit.close();
  });

  group('ThemeCubit', () {
    test('initial state is dark mode', () {
      expect(cubit.state, ThemeMode.dark);
    });

    test('isDark returns true when state is dark', () {
      expect(cubit.isDark, isTrue);
    });

    test('toggleTheme switches from dark to light', () {
      cubit.toggleTheme();

      expect(cubit.state, ThemeMode.light);
    });

    test('isDark returns false after switching to light', () {
      cubit.toggleTheme();

      expect(cubit.isDark, isFalse);
    });

    test('toggleTheme switches back to dark from light', () {
      cubit.toggleTheme();
      cubit.toggleTheme();

      expect(cubit.state, ThemeMode.dark);
    });

    test('emits light then dark on two consecutive toggles', () async {
      expect(
        cubit.stream,
        emitsInOrder([ThemeMode.light, ThemeMode.dark]),
      );

      cubit.toggleTheme();
      cubit.toggleTheme();
    });
  });
}
