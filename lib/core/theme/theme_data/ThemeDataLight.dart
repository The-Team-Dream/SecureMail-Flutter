import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:securemail/core/theme/app_color/AppColorLight.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';

ThemeData getThemeLight() {
  const color = AppColorLight;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',

    // ── Colors ──────────────────────────────────────────────
    primaryColor: AppColorLight.button1,
    scaffoldBackgroundColor: AppColorLight.background,
    dividerColor: AppColorLight.fieldBorder,

    colorScheme: const ColorScheme.light(
      primary:          AppColorLight.button1,
      onPrimary:        Colors.white,
      secondary:        AppColorLight.button2,
      onSecondary:      AppColorLight.text1,
      surface:          AppColorLight.card1,
      onSurface:        AppColorLight.text1,
      error:            Color(0xFFE24B4A),
      onError:          Colors.white,
    ),

    // ── AppBar ──────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor:    AppColorLight.background,
      foregroundColor:    AppColorLight.text1,
      elevation:          0,
      scrolledUnderElevation: 0,
      centerTitle:        false,
      titleTextStyle:     AppTextStyles.headingL.copyWith(color: AppColorLight.text1),
      systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor:            Colors.transparent,
        statusBarIconBrightness:   Brightness.dark,
      ),
    ),

    // ── Bottom Navigation Bar ────────────────────────────────
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:      AppColorLight.barBackground,
      selectedItemColor:    AppColorLight.barActiveIcon,
      unselectedItemColor:  AppColorLight.barInactiveIcon,
      showSelectedLabels:   true,
      showUnselectedLabels: true,
      type:                 BottomNavigationBarType.fixed,
      selectedLabelStyle:   AppTextStyles.labelS.copyWith(color: AppColorLight.barActiveIcon),
      unselectedLabelStyle: AppTextStyles.labelS.copyWith(color: AppColorLight.barInactiveIcon),
      elevation:            0,
    ),

    // ── Card ────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color:  AppColorLight.card1,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: AppColorLight.fieldBorder.withOpacity(0.5)),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical:   AppSpacing.x2,
      ),
    ),

    // ── Input / TextField ────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled:          true,
      fillColor:       AppColorLight.fieldBackground,
      hintStyle:       AppTextStyles.inputPlaceholder.copyWith(color: AppColorLight.fieldPlaceholder),
      contentPadding:  const EdgeInsets.symmetric(
        horizontal: AppSpacing.fieldPaddingH,
        vertical:   AppSpacing.fieldPaddingV,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:   BorderSide(color: AppColorLight.fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:   BorderSide(color: AppColorLight.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:   const BorderSide(color: AppColorLight.button1, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:   const BorderSide(color: Color(0xFFE24B4A)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:   const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
      ),
    ),

    // ── ElevatedButton ───────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:         AppColorLight.button1,
        foregroundColor:         Colors.white,
        disabledBackgroundColor: AppColorLight.button1.withOpacity(0.4),
        disabledForegroundColor: Colors.white.withOpacity(0.6),
        minimumSize:             const Size(double.infinity, AppSize.buttonHeightL),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        elevation:      0,
        textStyle:      AppTextStyles.labelL,
      ),
    ),

    // ── OutlinedButton ───────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorLight.button1,
        minimumSize:     const Size(double.infinity, AppSize.buttonHeightL),
        side:            const BorderSide(color: AppColorLight.button1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        elevation:  0,
        textStyle:  AppTextStyles.labelL,
      ),
    ),

    // ── TextButton ───────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorLight.button1,
        textStyle:       AppTextStyles.labelL,
      ),
    ),

    // ── Checkbox ─────────────────────────────────────────────
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColorLight.button1;
        return Colors.transparent;
      }),
      side: BorderSide(color: AppColorLight.fieldBorder, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
    ),

    // ── Divider ──────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color:     AppColorLight.fieldBorder,
      thickness: 1,
      space:     1,
    ),

    // ── Typography ───────────────────────────────────────────
    textTheme: TextTheme(
      displayLarge:  AppTextStyles.displayL.copyWith(color: AppColorLight.text1),
      displayMedium: AppTextStyles.displayM.copyWith(color: AppColorLight.text1),
      displaySmall:  AppTextStyles.displayS.copyWith(color: AppColorLight.text2),
      headlineLarge: AppTextStyles.headingL.copyWith(color: AppColorLight.text1),
      headlineMedium:AppTextStyles.headingM.copyWith(color: AppColorLight.text1),
      headlineSmall: AppTextStyles.headingS.copyWith(color: AppColorLight.text1),
      bodyLarge:     AppTextStyles.bodyL.copyWith(color: AppColorLight.text1),
      bodyMedium:    AppTextStyles.bodyM.copyWith(color: AppColorLight.text3),
      bodySmall:     AppTextStyles.bodyS.copyWith(color: AppColorLight.text3),
      labelLarge:    AppTextStyles.labelL.copyWith(color: AppColorLight.text1),
      labelMedium:   AppTextStyles.labelM.copyWith(color: AppColorLight.text3),
      labelSmall:    AppTextStyles.labelS.copyWith(color: AppColorLight.text3),
    ),
  );
}