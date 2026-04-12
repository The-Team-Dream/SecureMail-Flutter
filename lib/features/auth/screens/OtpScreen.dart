import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/features/auth/providers/otp_provider.dart';
import 'package:securemail/shared/widgets/app_error_banner.dart';
import 'package:securemail/shared/widgets/app_primary_button.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.email});
  final String email;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _submit() async {
    if (_otp.length < 6) return;

    final success = await ref.read(otpProvider.notifier).verifyOtp(
      email: widget.email,
      otp:   _otp,
    );

    if (success && mounted) {
      context.go(AppRoutes.login);
    }
  }

  Future<void> _resend() async {
    await ref.read(otpProvider.notifier).resendOtp(email: widget.email);
  }

  @override
  Widget build(BuildContext context) {
    final otpState      = ref.watch(otpProvider);
    final isLoading     = otpState.isLoading;
    final isResending   = otpState.isResending;
    final error         = otpState.error;
    final resendSuccess = otpState.resendSuccess;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: context.text1),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical:   AppSpacing.screenVertical,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color:        context.button1.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border:       Border.all(color: context.button1.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.mark_email_read_outlined, size: 40, color: context.button1),
                  ),
                  const SizedBox(height: AppSpacing.x6),

                  // Title
                  Text('Verify your email', style: AppTextStyles.displayS.copyWith(color: context.text1)),
                  const SizedBox(height: AppSpacing.x2),
                  Text(
                    'We sent a 6-digit code to',
                    style: AppTextStyles.bodyM.copyWith(color: context.text3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    widget.email,
                    style: AppTextStyles.bodyM.copyWith(color: context.button1, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.x8),

                  // OTP Fields
                  _buildOtpFields(),
                  const SizedBox(height: AppSpacing.x4),

                  // Error
                  if (error != null) ...[
                    AppErrorBanner(message: error),
                    const SizedBox(height: AppSpacing.x3),
                  ],

                  // Resend success
                  if (resendSuccess) ...[
                    _buildSuccess('OTP resent successfully!'),
                    const SizedBox(height: AppSpacing.x3),
                  ],

                  // Verify Button
                  AppPrimaryButton(
                    label:     'Verify Email',
                    onPressed: _submit,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: AppSpacing.x5),

                  // Resend
                  _buildResend(isResending),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
    // ── Success ───────────────────────────────────────────────
  Widget _buildSuccess(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x3),
      decoration: BoxDecoration(
        color:        context.button1.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border:       Border.all(color: context.button1.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: context.button1),
          const SizedBox(width: AppSpacing.x2),
          Expanded(child: Text(message, style: AppTextStyles.bodyS.copyWith(color: context.button1))),
        ],
      ),
    );
  }


  // ── OTP Fields ────────────────────────────────────────────
  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        return Container(
          width:  48,
          height: 56,
          margin: EdgeInsets.only(right: i < 5 ? AppSpacing.x2 : 0),
          child: TextFormField(
            controller:    _controllers[i],
            focusNode:     _focusNodes[i],
            keyboardType:  TextInputType.number,
            textAlign:     TextAlign.center,
            maxLength:     1,
            style:         AppTextStyles.headingL.copyWith(color: context.text1),
            decoration: InputDecoration(
              counterText: '',
              filled:      true,
              fillColor:   context.fieldBg,
              border:           OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: context.fieldBorder)),
              enabledBorder:    OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: context.fieldBorder)),
              focusedBorder:    OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: context.button1, width: 2)),
            ),
            onChanged: (val) {
              if (val.isNotEmpty && i < 5) {
                _focusNodes[i + 1].requestFocus();
              } else if (val.isEmpty && i > 0) {
                _focusNodes[i - 1].requestFocus();
              }
              if (_otp.length == 6) _submit();
            },
          ),
        );
      }),
    );
  }

  // ── Error → replaced by AppErrorBanner ─────────────────

  // ── Verify Button → replaced by AppPrimaryButton ────────

  // ── Resend ────────────────────────────────────────────────
  Widget _buildResend(bool isResending) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Didn't receive the code? ", style: AppTextStyles.bodyS.copyWith(color: context.text3)),
        GestureDetector(
          onTap: isResending ? null : _resend,
          child: isResending
              ? SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: context.button1))
              : Text('Resend', style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w600, color: context.text4)),
        ),
      ],
    );
  }
}