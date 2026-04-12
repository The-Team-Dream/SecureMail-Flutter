import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';

InputDecoration appInputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.inputPlaceholder
          .copyWith(color: context.fieldPlaceholder),
      filled: true,
      fillColor: context.fieldBg,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.fieldPaddingH,
          vertical: AppSpacing.fieldPaddingV),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: context.fieldBorder)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: context.fieldBorder)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide(color: context.button1, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: Color(0xFFE24B4A))),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5)),
    );
  }