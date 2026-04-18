// lib/core/theme/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeState {
  final ThemeMode themeMode;
  const ThemeState({this.themeMode = ThemeMode.system});

  bool get isDarkMode => themeMode == ThemeMode.dark;

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(themeMode: themeMode ?? this.themeMode);
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(const ThemeState());

  void toggleTheme() {
    state = state.copyWith(
      themeMode: state.isDarkMode ? ThemeMode.light : ThemeMode.dark,
    );
  }

  void setDarkMode() {
    state = state.copyWith(themeMode: ThemeMode.dark);
  }

  void setLightMode() {
    state = state.copyWith(themeMode: ThemeMode.light);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);
