import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:securemail/core/theme/app_color/AppColorDark.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';

ThemeData getThemeDark() {

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',

    // ── Colors ──────────────────────────────────────────────
    primaryColor: AppColorDark.button1,
    scaffoldBackgroundColor: AppColorDark.background,
    dividerColor: AppColorDark.fieldBorder.withOpacity(0.3),

    colorScheme: const ColorScheme.dark(
      primary:          AppColorDark.button1,
      onPrimary:        Colors.white,
      secondary:        AppColorDark.button2,
      onSecondary:      AppColorDark.text1,
      surface:          AppColorDark.card1,
      onSurface:        AppColorDark.text1,
      error:            Color(0xFFE24B4A),
      onError:          Colors.white,
    ),

    // ── AppBar ──────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor:    AppColorDark.background,
      foregroundColor:    AppColorDark.text1,
      elevation:          0,
      scrolledUnderElevation: 0,
      centerTitle:        false,
      titleTextStyle:     AppTextStyles.headingL.copyWith(color: AppColorDark.text1),
      systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
        statusBarColor:          Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),

    // ── Bottom Navigation Bar ────────────────────────────────
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:      AppColorDark.barBackground,
      selectedItemColor:    AppColorDark.barActiveIcon,
      unselectedItemColor:  AppColorDark.barInactiveIcon,
      showSelectedLabels:   true,
      showUnselectedLabels: true,
      type:                 BottomNavigationBarType.fixed,
      selectedLabelStyle:   AppTextStyles.labelS.copyWith(color: AppColorDark.barActiveIcon),
      unselectedLabelStyle: AppTextStyles.labelS.copyWith(color: AppColorDark.barInactiveIcon),
      elevation:            0,
    ),

    // ── Card ────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color:  AppColorDark.card1,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: AppColorDark.fieldBorder.withOpacity(0.2)),
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical:   AppSpacing.x2,
      ),
    ),

    // ── Input / TextField ────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled:          true,
      fillColor:       AppColorDark.fieldBackground,
      hintStyle:       AppTextStyles.inputPlaceholder.copyWith(color: AppColorDark.fieldPlaceholder),
      contentPadding:  const EdgeInsets.symmetric(
        horizontal: AppSpacing.fieldPaddingH,
        vertical:   AppSpacing.fieldPaddingV,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:   BorderSide(color: AppColorDark.fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:   BorderSide(color: AppColorDark.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide:   const BorderSide(color: AppColorDark.button1, width: 1.5),
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
        backgroundColor:         AppColorDark.button1,
        foregroundColor:         Colors.white,
        disabledBackgroundColor: AppColorDark.button1.withOpacity(0.4),
        disabledForegroundColor: Colors.white.withOpacity(0.6),
        minimumSize:             const Size(double.infinity, AppSize.buttonHeightL),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        elevation:  0,
        textStyle:  AppTextStyles.labelL,
      ),
    ),

    // ── OutlinedButton ───────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorDark.button1,
        minimumSize:     const Size(double.infinity, AppSize.buttonHeightL),
        side:            const BorderSide(color: AppColorDark.button1),
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
        foregroundColor: AppColorDark.button1,
        textStyle:       AppTextStyles.labelL,
      ),
    ),

    // ── Checkbox ─────────────────────────────────────────────
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColorDark.button1;
        return Colors.transparent;
      }),
      side: BorderSide(color: AppColorDark.fieldBorder, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
    ),

    // ── Divider ──────────────────────────────────────────────
    dividerTheme: DividerThemeData(
      color:     AppColorDark.fieldBorder.withOpacity(0.2),
      thickness: 1,
      space:     1,
    ),

    // ── Typography ───────────────────────────────────────────
    textTheme: TextTheme(
      displayLarge:  AppTextStyles.displayL.copyWith(color: AppColorDark.text1),
      displayMedium: AppTextStyles.displayM.copyWith(color: AppColorDark.text1),
      displaySmall:  AppTextStyles.displayS.copyWith(color: AppColorDark.text2),
      headlineLarge: AppTextStyles.headingL.copyWith(color: AppColorDark.text1),
      headlineMedium:AppTextStyles.headingM.copyWith(color: AppColorDark.text1),
      headlineSmall: AppTextStyles.headingS.copyWith(color: AppColorDark.text1),
      bodyLarge:     AppTextStyles.bodyL.copyWith(color: AppColorDark.text1),
      bodyMedium:    AppTextStyles.bodyM.copyWith(color: AppColorDark.text3),
      bodySmall:     AppTextStyles.bodyS.copyWith(color: AppColorDark.text3),
      labelLarge:    AppTextStyles.labelL.copyWith(color: AppColorDark.text1),
      labelMedium:   AppTextStyles.labelM.copyWith(color: AppColorDark.text3),
      labelSmall:    AppTextStyles.labelS.copyWith(color: AppColorDark.text3),
    ),
  );
}