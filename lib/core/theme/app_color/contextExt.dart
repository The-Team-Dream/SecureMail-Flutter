import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_color/AppColorDark.dart';
import 'package:securemail/core/theme/app_color/AppColorLight.dart';

extension AppColorsX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ── Background ────────────────────────────────────────────
  Color get bgColor =>
      isDark ? AppColorDark.background : AppColorLight.background;

  // ── Buttons ───────────────────────────────────────────────
  Color get button1 => isDark ? AppColorDark.button1 : AppColorLight.button1;
  Color get button2 => isDark ? AppColorDark.button2 : AppColorLight.button2;

  // ── Text ──────────────────────────────────────────────────
  Color get text1 => isDark ? AppColorDark.text1 : AppColorLight.text1;
  Color get text2 => isDark ? AppColorDark.text2 : AppColorLight.text2;
  Color get text3 => isDark ? AppColorDark.text3 : AppColorLight.text3;
  Color get text4 => isDark ? AppColorDark.text4 : AppColorLight.text4;

  // ── Cards ─────────────────────────────────────────────────
  Color get card1 => isDark ? AppColorDark.card1 : AppColorLight.card1;
  Color get card2 => isDark ? AppColorDark.card2 : AppColorLight.card2;
  Color get card3 => isDark ? AppColorDark.card3 : AppColorLight.card3;

  // ── Input Fields ──────────────────────────────────────────
  Color get fieldBg =>
      isDark ? AppColorDark.fieldBackground : AppColorLight.fieldBackground;
  Color get fieldBorder =>
      isDark ? AppColorDark.fieldBorder : AppColorLight.fieldBorder;
  Color get fieldPlaceholder =>
      isDark ? AppColorDark.fieldPlaceholder : AppColorLight.fieldPlaceholder;
  Color get fieldText =>
      isDark ? AppColorDark.fieldText : AppColorLight.fieldText;

  // ── Bottom Navigation Bar ─────────────────────────────────
  Color get barBg =>
      isDark ? AppColorDark.barBackground : AppColorLight.barBackground;
  Color get barActiveIcon =>
      isDark ? AppColorDark.barActiveIcon : AppColorLight.barActiveIcon;
  Color get barInactiveIcon =>
      isDark ? AppColorDark.barInactiveIcon : AppColorLight.barInactiveIcon;
  Color get securityReport =>
      isDark ? AppColorDark.securityReport1 : AppColorLight.securityReport1;
  Color get securityReport2 =>
      isDark ? AppColorDark.securityReport2 : AppColorLight.securityReport2;
  Color get lamp => isDark ? AppColorDark.lamp : AppColorLight.card2;
  Color get securityReport3 =>
      isDark ? AppColorDark.securityReport3 : AppColorLight.securityReport3;

  // ── Semantic Colors ───────────────────────────────────────
  Color get danger => isDark ? AppColorDark.danger : AppColorLight.danger;
  Color get success => isDark ? AppColorDark.success : AppColorLight.success;
  Color get warning => isDark ? AppColorDark.warning : AppColorLight.warning;
  Color get info => isDark ? AppColorDark.info : AppColorLight.info;
}
