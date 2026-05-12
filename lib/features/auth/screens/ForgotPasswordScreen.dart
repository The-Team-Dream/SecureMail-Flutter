import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/utils/validators.dart';
import 'package:securemail/features/auth/providers/auth_provider.dart';
import 'package:securemail/shared/widgets/app_error_banner.dart';
import 'package:securemail/shared/widgets/app_primary_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool  _sent      = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).forgetPassword(
      email: _emailCtrl.text.trim(),
    );

    if (success && mounted) {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final error     = authState.error;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        titleTextStyle: AppTextStyles.labelL.copyWith(color: context.text1),
        title: const Text('Reset Password'),
        backgroundColor: context.bgColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20, color: context.text1),
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
              child: _sent ? _buildSuccessState() : _buildFormState(isLoading, error),
            ),
          ),
        ),
      ),
    );
  }

  // ── Form State ────────────────────────────────────────────
  Widget _buildFormState(bool isLoading, String? error) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color:        context.button1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border:       Border.all(color: context.button1.withOpacity(0.3)),
            ),
            child: Icon(Icons.lock_reset_outlined, size: 40, color: context.button1),
          ),
          const SizedBox(height: AppSpacing.x6),

          Text('Forgot Password?', style: AppTextStyles.displayS.copyWith(color: context.text1)),
          const SizedBox(height: AppSpacing.x2),
          Text(
            "Enter your email address associated with your account and we'll send you a link to reset your password.",
            style: AppTextStyles.bodyM.copyWith(color: context.text3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.x16),
          const SizedBox(height: AppSpacing.x8),

          TextFormField(
            controller:       _emailCtrl,
            keyboardType:     TextInputType.emailAddress,
            autocorrect:      false,
            textInputAction:  TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            style:            AppTextStyles.inputText.copyWith(color: context.fieldText),
            decoration: InputDecoration(
              hintText:    'Email',
              hintStyle:   AppTextStyles.inputPlaceholder.copyWith(color: context.fieldPlaceholder),
              prefixIcon:  Icon(Icons.email_outlined, size: AppIconSize.md, color: context.fieldPlaceholder),
              filled:      true,
              fillColor:   context.fieldBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.fieldPaddingH, vertical: AppSpacing.fieldPaddingV),
              border:             OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xl), borderSide: BorderSide(color: context.fieldBorder)),
              enabledBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xl), borderSide: BorderSide(color: context.fieldBorder)),
              focusedBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xl), borderSide: BorderSide(color: context.button1, width: 1.5)),
              errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xl), borderSide: const BorderSide(color: Color(0xFFE24B4A))),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.xl), borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5)),
            ),
            validator: Validators.email,
          ),

          if (error != null) ...[
            const SizedBox(height: AppSpacing.x3),
            AppErrorBanner(message: error),
          ],

          const SizedBox(height: AppSpacing.x5),

          AppPrimaryButton(
            label:     'Send Reset Link',
            onPressed: _submit,
            isLoading: isLoading,
          ),
          const SizedBox(height: AppSpacing.x5),

          GestureDetector(
            onTap: () => context.pop(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 16, color: context.text4),
                const SizedBox(width: AppSpacing.x1),
                Text('Back to Login', style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w600, color: context.text4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Success State ─────────────────────────────────────────
  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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

        Text('Check your email', style: AppTextStyles.displayS.copyWith(color: context.text1)),
        const SizedBox(height: AppSpacing.x2),
        Text(
          'We sent a reset link to',
          style: AppTextStyles.bodyM.copyWith(color: context.text3),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.x1),
        Text(
          _emailCtrl.text,
          style: AppTextStyles.bodyM.copyWith(color: context.button1, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.x8),
  
        AppPrimaryButton(
          label:     'Back to Login',
          onPressed: () => context.go(AppRoutes.login),
          isLoading: false,
        ),
      ],
    );
  }
}