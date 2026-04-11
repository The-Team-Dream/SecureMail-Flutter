import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToPolicy = false;

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
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          confirmPassword: _confirmPassCtrl.text,
          username: _usernameCtrl.text.trim(),
        );

    if (success && mounted) {
      context.push(AppRoutes.otp, extra: _emailCtrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final error = authState.error;

    return Scaffold(
      body: Container(
      decoration: BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: context.isDark
        ? [
                  const Color.fromARGB(181, 17, 52, 43),
                  const Color.fromARGB(255, 3, 13, 10),
                  const Color.fromARGB(136, 17, 52, 43)
                ]
        : [const Color(0xFFF2FBF7), const Color(0xFFE8F6F2), const Color(0xFFF2FBF7)],
       
        
  ),
),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.screenVertical,
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
                    const SizedBox(height: AppSpacing.x1),
                    _buildPrivacyPolicy(),
                    const SizedBox(height: AppSpacing.x5),
                    _buildRegisterButton(isLoading),
                    const SizedBox(height: AppSpacing.x5),
                    _buildFooter(),
                    const SizedBox(height: AppSpacing.x12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),);
  }

  // ── Logo ──────────────────────────────────────────────────
  Widget _buildLogo() {
    return Center(
      child: SizedBox(
        width: 90,
        height: 90,
        child: Image.asset(
          'assets/images/splash.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.shield_outlined, size: 150, color: context.button1),
        ),
      ),
    );
  }

  // ── Title ─────────────────────────────────────────────────
  Widget _buildTitle() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Join Secure',
                style: AppTextStyles.displayS.copyWith(color: context.text1)),
            Text('Mail',
                style: AppTextStyles.displayS.copyWith(color: context.button1)),
          ],
        ),
        const SizedBox(height: AppSpacing.x1),
        Center(
            child: Text('Secure your communication with SecureMail',
                style: AppTextStyles.bodyM.copyWith(color: context.text3))),
        const SizedBox(height: AppSpacing.x8),
      ],
    );
  }

  // ── Fields ────────────────────────────────────────────────
  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameCtrl,
      textInputAction: TextInputAction.next,
      style: AppTextStyles.inputText.copyWith(color: context.fieldText),
      decoration: _inputDecoration('Name', Icons.person_outline),
      validator: Validators.name,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      textInputAction: TextInputAction.next,
      style: AppTextStyles.inputText.copyWith(color: context.fieldText),
      decoration: _inputDecoration('Email', Icons.email_outlined),
      validator: Validators.email,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      style: AppTextStyles.inputText.copyWith(color: context.fieldText),
      decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: AppIconSize.sm,
            color: context.fieldPlaceholder,
          ),
        ),
      ),
      validator: Validators.password,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPassCtrl,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
      style: AppTextStyles.inputText.copyWith(color: context.fieldText),
      decoration:
          _inputDecoration('Confirm Password', Icons.lock_outline).copyWith(
        suffixIcon: GestureDetector(
          onTap: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword),
          child: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: AppIconSize.sm,
            color: context.fieldPlaceholder,
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
        color: const Color(0xFFE24B4A).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: const Color(0xFFE24B4A).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: Color(0xFFE24B4A)),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
              child: Text(error,
                  style: AppTextStyles.bodyS
                      .copyWith(color: const Color(0xFFE24B4A)))),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text('Register',
                style: AppTextStyles.labelL.copyWith(color: Colors.white)),
      ),
    );
  }

  // ── Privacy Policy ────────────────────────────────────────
  Widget _buildPrivacyPolicy() {
    return Row(
      children: [
        Checkbox(
          value: _agreeToPolicy,
          onChanged: (val) => setState(() => _agreeToPolicy = val ?? false),
          activeColor: context.button1,
          side: BorderSide(color: context.fieldBorder, width: 1.5),
          shape: const CircleBorder(),
        ),
        RichText(
          text: TextSpan(
            style: AppTextStyles.bodyS.copyWith(color: context.text3),
            children: [
              const TextSpan(text: 'I agree to the '),
              TextSpan(
                text: 'Privacy Policy',
                style: AppTextStyles.bodyS.copyWith(color: context.text4),
              ),
              const TextSpan(text: ' and '),
              TextSpan(
                text: 'Terms of Service',
                style: AppTextStyles.bodyS.copyWith(color: context.text4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────
  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyS.copyWith(color: context.text3),
          children: [
            const TextSpan(text: 'Already have an account? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Text('Log in',
                    style: AppTextStyles.bodyS.copyWith(
                        fontWeight: FontWeight.w600, color: context.text4)),
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
      hintText: hint,
      hintStyle: AppTextStyles.inputPlaceholder
          .copyWith(color: context.fieldPlaceholder),
      prefixIcon: Icon(prefixIcon,
          size: AppIconSize.md, color: context.fieldPlaceholder),
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
}
