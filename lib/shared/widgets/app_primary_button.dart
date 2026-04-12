import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';

/// Reusable primary ElevatedButton with built-in loading state.
/// Extracted from: LoginScreen, RegisterScreen, ForgotPasswordScreen,
///                 OtpScreen, ChangePasswordScreen
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String       label;
  final VoidCallback onPressed;
  final bool         isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  double.infinity,
      height: AppSize.buttonHeightL,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width:  20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color:       Colors.white,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.labelL.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}
