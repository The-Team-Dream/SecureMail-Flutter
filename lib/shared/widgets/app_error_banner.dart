import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';

/// Reusable inline error banner.
/// Extracted from: LoginScreen, RegisterScreen, ForgotPasswordScreen, OtpScreen
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x3),
      decoration: BoxDecoration(
        color: const Color(0xFFE24B4A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFE24B4A).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: Color(0xFFE24B4A)),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyS.copyWith(color: const Color(0xFFE24B4A)),
            ),
          ),
        ],
      ),
    );
  }
}
