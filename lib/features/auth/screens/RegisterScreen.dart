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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _usernameCtrl    = TextEditingController();
  final _emailCtrl       = TextEditingController();
  final _passwordCtrl    = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
      email:           _emailCtrl.text.trim(),
      password:        _passwordCtrl.text,
      confirmPassword: _confirmPassCtrl.text,
      username:        _usernameCtrl.text.trim(),
    );

    if (success && mounted) {
      // بنبعت الـ email للـ OTP screen عشان يستخدمه في الـ verify
      context.push(AppRoutes.otp, extra: _emailCtrl.text.trim());
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical:   AppSpacing.screenVertical,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLogo(),
                    _buildTitle(),
                    const SizedBox(height: AppSpacing.x8),
                    _buildUsernameField(),
                    const SizedBox(height: AppSpacing.x4),
                    _buildEmailField(),
                    const SizedBox(height: AppSpacing.x4),
                    _buildPasswordField(),
                    const SizedBox(height: AppSpacing.x4),
                    _buildConfirmPasswordField(),
                    if (error != null) ...[
                      const SizedBox(height: AppSpacing.x3),
                      _buildError(error),
                    ],
                    const SizedBox(height: AppSpacing.x5),
                    _buildRegisterButton(isLoading),
                    const SizedBox(height: AppSpacing.x4),
                    _buildPrivacyPolicy(),
                    const SizedBox(height: AppSpacing.x5),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Logo ──────────────────────────────────────────────────
  Widget _buildLogo() {
    return Center(
      child: SizedBox(
        width: 90, height: 90,
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(Icons.shield_outlined, size: 80, color: _button1),
        ),
      ),
    );
  }

  // ── Title ─────────────────────────────────────────────────
  Widget _buildTitle() {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.x4),
        Center(child: Text('Create Account', style: AppTextStyles.displayS.copyWith(color: _text1))),
        const SizedBox(height: AppSpacing.x2),
        Center(child: Text('Secure your inbox today', style: AppTextStyles.bodyM.copyWith(color: _text3))),
      ],
    );
  }

  // ── Fields ────────────────────────────────────────────────
  Widget _buildUsernameField() {
    return TextFormField(
      controller:      _usernameCtrl,
      textInputAction: TextInputAction.next,
      style:           AppTextStyles.inputText.copyWith(color: _fieldText),
      decoration:      _inputDecoration('Username', Icons.person_outline),
      validator:       Validators.name,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller:      _emailCtrl,
      keyboardType:    TextInputType.emailAddress,
      autocorrect:     false,
      textInputAction: TextInputAction.next,
      style:           AppTextStyles.inputText.copyWith(color: _fieldText),
      decoration:      _inputDecoration('Email', Icons.email_outlined),
      validator:       Validators.email,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller:      _passwordCtrl,
      obscureText:     _obscurePassword,
      textInputAction: TextInputAction.next,
      style:           AppTextStyles.inputText.copyWith(color: _fieldText),
      decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: AppIconSize.sm, color: _fieldPlaceholder,
          ),
        ),
      ),
      validator: Validators.password,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller:       _confirmPassCtrl,
      obscureText:      _obscureConfirmPassword,
      textInputAction:  TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
      style:            AppTextStyles.inputText.copyWith(color: _fieldText),
      decoration: _inputDecoration('Confirm Password', Icons.lock_outline).copyWith(
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          child: Icon(
            _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: AppIconSize.sm, color: _fieldPlaceholder,
          ),
        ),
      ),
      validator: Validators.confirmPassword(_passwordCtrl.text),
    );
  }

  // ── Error ─────────────────────────────────────────────────
  Widget _buildError(String error) {
    return Container(
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
    );
  }

  // ── Register Button ───────────────────────────────────────
  Widget _buildRegisterButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: AppSize.buttonHeightL,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text('Create Account', style: AppTextStyles.labelL.copyWith(color: Colors.white)),
      ),
    );
  }

  // ── Privacy Policy ────────────────────────────────────────
  Widget _buildPrivacyPolicy() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTextStyles.bodyS.copyWith(color: _text3),
          children: [
            const TextSpan(text: 'By creating an account, you agree to our '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () { /* TODO: Privacy Policy Screen */ },
                child: Text(
                  'Privacy Policy',
                  style: AppTextStyles.bodyS.copyWith(
                    color:           _text4,
                    fontWeight:      FontWeight.w600,
                    decoration:      TextDecoration.underline,
                    decorationColor: _text4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────
  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyS.copyWith(color: _text3),
          children: [
            const TextSpan(text: 'Already have an account? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Text('Log in', style: AppTextStyles.bodyS.copyWith(fontWeight: FontWeight.w600, color: _text4)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Input Decoration ──────────────────────────────────────
  InputDecoration _inputDecoration(String hint, IconData prefixIcon) {
    return InputDecoration(
      hintText:    hint,
      hintStyle:   AppTextStyles.inputPlaceholder.copyWith(color: _fieldPlaceholder),
      prefixIcon:  Icon(prefixIcon, size: AppIconSize.md, color: _fieldPlaceholder),
      filled:      true,
      fillColor:   _fieldBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.fieldPaddingH, vertical: AppSpacing.fieldPaddingV),
      border:             OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: _fieldBorder)),
      enabledBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: _fieldBorder)),
      focusedBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide(color: _button1, width: 1.5)),
      errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: Color(0xFFE24B4A))),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5)),
    );
  }
}
