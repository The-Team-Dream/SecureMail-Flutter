import 'package:flutter/material.dart';

/// SecureMail — Typography System
/// Font Family: Inter
/// Usage: AppTextStyles.headingL, AppTextStyles.bodyM, etc.
class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Inter';

  // ── Display ───────────────────────────────────────────────
  /// 32px · Bold — Screen titles
  static const TextStyle displayL = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  /// 28px · SemiBold — Section headers
  static const TextStyle displayM = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.3,
  );

  /// 24px · SemiBold — Card headers
  static const TextStyle displayS = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  // ── Heading ───────────────────────────────────────────────
  /// 20px · SemiBold — AppBar title, Dialog title
  static const TextStyle headingL = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// 18px · SemiBold — Section title
  static const TextStyle headingM = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  /// 16px · Medium — Sub-section title
  static const TextStyle headingS = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ── Body ──────────────────────────────────────────────────
  /// 15px · Regular — Default body text
  static const TextStyle bodyL = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 14px · Regular — Secondary body, email preview
  static const TextStyle bodyM = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 13px · Regular — Metadata, timestamps
  static const TextStyle bodyS = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  // ── Label ─────────────────────────────────────────────────
  /// 15px · Medium — Buttons
  static const TextStyle labelL = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  /// 13px · Medium — Tags, Badges, small buttons
  static const TextStyle labelM = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  /// 12px · Medium — Overlines, navigation labels
  static const TextStyle labelS = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.3,
  );

  // ── Caption ───────────────────────────────────────────────
  /// 11px · Regular — Tiny helper text
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ── Input ─────────────────────────────────────────────────
  /// 14px · Regular — Input field text
  static const TextStyle inputText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 14px · Regular — Input placeholder
  static const TextStyle inputPlaceholder = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
}