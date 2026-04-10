import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_color/AppColorLight.dart';
import 'package:securemail/core/theme/app_color/AppColorDark.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/utils/validators.dart';
import 'package:securemail/features/auth/providers/auth_provider.dart';

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

  // ── Colors ────────────────────────────────────────────────
  bool  get _isDark           => Theme.of(context).brightness == Brightness.dark;
  Color get _background       => _isDark ? AppColorDark.background       : AppColorLight.background;
  Color get _text1            => _isDark ? AppColorDark.text1            : AppColorLight.text1;
  Color get _text3            => _isDark ? AppColorDark.text3            : AppColorLight.text3;
  Color get _text4            => _isDark ? AppColorDark.text4            : AppColorLight.text4;
  Color get _button1          => _isDark ? AppColorDark.button1          : AppColorLight.button1;
  Color get _fieldBackground  => _isDark ? AppColorDark.fieldBackground  : AppColorLight.fieldBackground;
  Color get _fieldBorder      => _isDark ? AppColorDark.fieldBorder      : AppColorLight.fieldBorder;
  Color get _fieldPlaceholder => _isDark ? AppColorDark.fieldPlaceholder : AppColorLight.fieldPlaceholder;
  Color get _fieldText        => _isDark ? AppColorDark.fieldText        : AppColorLight.fieldText;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final error     = authState.error;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: _text1),
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
          // Icon
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color:        _button1.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border:       Border.all(color: _button1.withOpacity(0.3)),
            ),
            child: Icon(Icons.lock_reset_outlined, size: 40, color: _button1),
          ),
          const SizedBox(height: AppSpacing.x6),

          Text('Forgot Password?', style: AppTextStyles.displayS.copyWith(color: _text1)),
          const SizedBox(height: AppSpacing.x2),
          Text(
            "No worries! Enter your email and we'll send you a reset link.",
            style: AppTextStyles.bodyM.copyWith(color: _text3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.x8),

          // Email Field
          TextFormField(
            controller:      _emailCtrl,
            keyboardType:    TextInputType.emailAddress,
            autocorrect:     false,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            style:           AppTextStyles.inputText.copyWith(color: _fieldText),
            decoration: InputDecoration(
              hintText:    'Email',
              hintStyle:   AppTextStyles.inputPlaceholder.copyWith(color: _fieldPlaceholder),
              prefixIcon:  Icon(Icons.email_outlined, size: AppIconSize.md, color: _fieldPlaceholder),
              filled:      true,
              fillColor:   _fieldBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.fieldPaddingH, vertical: AppSpacing.fieldPaddingV),
              border:             OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: _fieldBorder)),
              enabledBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: _fieldBorder)),
              focusedBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: _button1, width: 1.5)),
              errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: Color(0xFFE24B4A))),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5)),
            ),
            validator: Validators.email,
          ),

          if (error != null) ...[
            const SizedBox(height: AppSpacing.x3),
            Container(
              padding: const EdgeInsets.all(AppSpacing.x3),
              decoration: BoxDecoration(
                color:        const Color(0xFFE24B4A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border:       Border.all(color: const Color(0xFFE24B4A).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: Color(0xFFE24B4A)),
                  const SizedBox(width: AppSpacing.x2),
                  Expanded(child: Text(error, style: AppTextStyles.bodyS.copyWith(color: const Color(0xFFE24B4A)))),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.x5),

          // Send Button
          SizedBox(
            width: double.infinity,
            height: AppSize.buttonHeightL,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              ),
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Send Reset Link', style: AppTextStyles.labelL.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: AppSpacing.x5),

          // Back to Login
          GestureDetector(
            onTap: () => context.pop(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 16, color: _text4),
                const SizedBox(width: AppSpacing.x1),
                Text('Back to Login', style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w600, color: _text4)),
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
            color:        _button1.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border:       Border.all(color: _button1.withOpacity(0.3)),
          ),
          child: Icon(Icons.mark_email_read_outlined, size: 40, color: _button1),
        ),
        const SizedBox(height: AppSpacing.x6),

        Text('Check your email', style: AppTextStyles.displayS.copyWith(color: _text1)),
        const SizedBox(height: AppSpacing.x2),
        Text(
          'We sent a reset link to',
          style: AppTextStyles.bodyM.copyWith(color: _text3),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.x1),
        Text(
          _emailCtrl.text,
          style: AppTextStyles.bodyM.copyWith(color: _button1, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.x8),

        SizedBox(
          width: double.infinity,
          height: AppSize.buttonHeightL,
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            ),
            child: Text('Back to Login', style: AppTextStyles.labelL.copyWith(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
