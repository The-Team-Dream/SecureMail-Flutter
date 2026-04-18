import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';

/// Reusable SnackBar extension on [BuildContext] to avoid duplicating
/// the same _showSnackBar method in every screen.
extension ContextSnackBars on BuildContext {
  /// Show a floating SnackBar.
  ///
  /// Set [isError] to `true` for red background (errors),
  /// or `false` for the primary button color (success / info).
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyM.copyWith(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red : button1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}
