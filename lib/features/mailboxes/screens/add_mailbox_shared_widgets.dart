
import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';

// ─── Step Progress ────────────────────────────────────────

class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    final progressPercent = current * 20;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Step $current of 5',
                style: AppTextStyles.bodyS.copyWith(color: context.text3)),
            Text('$progressPercent% COMPLETE',
                style: AppTextStyles.labelS.copyWith(
                  color: context.button1,
                  letterSpacing: 1,
                )),
          ],
        ),
        const SizedBox(height: AppSpacing.x3),
        Row(
          children: List.generate(
            5,
            (i) => Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                height: 6, // Slightly thicker for a premium feel
                margin: EdgeInsets.only(right: i < 4 ? AppSpacing.x2 : 0),
                decoration: BoxDecoration(
                  color: i < current
                      ? context.button1
                      : context.button1.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section Label ────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: AppTextStyles.labelS.copyWith(
          color: context.text2,
          letterSpacing: 1.5,
        ),
      );
}

// ─── Encryption Toggle ────────────────────────────────────

class EncryptionToggle<T> extends StatelessWidget {
  const EncryptionToggle({
    super.key,
    required this.values,
    required this.selected,
    required this.labels,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final Map<T, String> labels;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.fieldBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Row(
        children: values.map((type) {
          final isSelected = selected == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3),
                decoration: BoxDecoration(
                  color: isSelected ? context.button1 : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Center(
                  child: Text(
                    labels[type]!,
                    style: AppTextStyles.bodyS.copyWith(
                      color: isSelected ? Colors.white : context.text3,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step Buttons (Back & Next) ────────────────────────────

class StepButtons extends StatelessWidget {
  const StepButtons({
    super.key,
    required this.onBack,
    required this.onNext,
    this.nextLabel = 'Next Step',
    this.isLoading = false,
  });

  final VoidCallback onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppSize.buttonHeightL,
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.button1,
                side: BorderSide(color: context.button1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full)),
              ),
              child: Text('Back',
                  style: AppTextStyles.labelL.copyWith(
                    color: context.button1,
                  )),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.itemGap),
        Expanded(
          child: SizedBox(
            height: AppSize.buttonHeightL,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.button1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.full)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(nextLabel,
                      style: AppTextStyles.labelL.copyWith(
                        color: Colors.white,
                      )),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Secure Footer ────────────────────────────────────────

class SecureFooter extends StatelessWidget {
  const SecureFooter({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined,
                size: AppIconSize.xs, color: context.text3),
            const SizedBox(width: AppSpacing.x1 + 2),
            Text('SECUREMAIL',
                style: AppTextStyles.labelS.copyWith(
                  color: context.text3,
                  letterSpacing: 2,
                )),
          ],
        ),
      );
}

// ─── Input Decoration Helper ──────────────────────────────

InputDecoration stepInputDecoration(
  BuildContext context,
  String hint, {
  Widget? prefix,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.bodyM.copyWith(color: context.text3),
    prefixIcon: prefix,
    suffixIcon: suffix,
    filled: true,
    fillColor: context.fieldBg,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.x4,
      vertical: AppSpacing.cardPaddingV,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: context.fieldBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: context.fieldBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: context.button1, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
  );
}

// ─── Provider Icons ───────────────────────────────────────

class GmailIcon extends StatelessWidget {
  const GmailIcon({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: AppSize.avatarMd,
        height: AppSize.avatarMd,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(Icons.mail, color: const Color(0xFFEA4335), size: AppIconSize.md + 2),
      );
}

class OutlookIcon extends StatelessWidget {
  const OutlookIcon({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: AppSize.avatarMd,
        height: AppSize.avatarMd,
        decoration: BoxDecoration(
          color: const Color(0xFF0078D4),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(Icons.email_outlined, color: Colors.white, size: AppIconSize.md + 2),
      );
}

class CustomIcon extends StatelessWidget {
  const CustomIcon({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: AppSize.avatarMd,
        height: AppSize.avatarMd,
        decoration: BoxDecoration(
          color: context.button1.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(Icons.tune, color: context.button1, size: AppIconSize.md + 2),
      );
} 