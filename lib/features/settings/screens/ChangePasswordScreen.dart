import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/utils/validators.dart';
import 'package:securemail/shared/widgets/app_border_outline.dart';
import 'package:securemail/shared/widgets/app_primary_button.dart';
import 'package:securemail/shared/widgets/auth_gradient_background.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: استبدل بـ API call حقيقي
    // await ApiClient.instance.patch(
    //   ApiConstants.changePassword,
    //   data: {
    //     'currentPassword': _currentPassCtrl.text,
    //     'newPassword':     _newPassCtrl.text,
    //   },
    // );

    await Future.delayed(const Duration(milliseconds: 1200)); // mock delay

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Password changed successfully.',
          style: AppTextStyles.bodyM.copyWith(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F8A70),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: AuthGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
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
                          const SizedBox(height: AppSpacing.x4),
                          _buildHeader(),
                          const SizedBox(height: AppSpacing.x8),
                          _buildCurrentPasswordField(),
                          const SizedBox(height: AppSpacing.x4),
                          _buildNewPasswordField(),
                          const SizedBox(height: AppSpacing.x4),
                          _buildConfirmPasswordField(),
                          const SizedBox(height: AppSpacing.x8),
                          _buildPasswordHint(),
                          const SizedBox(height: AppSpacing.x8),
                          AppPrimaryButton(
                            label: 'Update Password',
                            onPressed: _submit,
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: AppSpacing.x12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: context.button2.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(
            Icons.key_outlined,
            size: AppIconSize.xl,
            color: context.button1,
          ),
        ),
        const SizedBox(height: AppSpacing.x4),
        Text(
          'Update Your Password',
          style: AppTextStyles.displayS.copyWith(color: context.text1),
        ),
        const SizedBox(height: AppSpacing.x2),
        Text(
          'Choose a strong password to keep your\naccount secure.',
          style: AppTextStyles.bodyM.copyWith(color: context.text3),
        ),
      ],
    );
  }

  // ── Fields ────────────────────────────────────────────────
  Widget _buildCurrentPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Current Password'),
        const SizedBox(height: AppSpacing.x2),
        TextFormField(
          controller: _currentPassCtrl,
          obscureText: _obscureCurrent,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.inputText.copyWith(color: context.fieldText),
          decoration: appInputDecoration(context, 'Enter your current password')
              .copyWith(
            prefixIcon: Icon(
              Icons.lock_outline,
              size: AppIconSize.md,
              color: context.fieldPlaceholder,
            ),
            suffixIcon: _eyeToggle(
              obscure: _obscureCurrent,
              onToggle: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
            ),
          ),
          validator: Validators.password,
        ),
      ],
    );
  }

  Widget _buildNewPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('New Password'),
        const SizedBox(height: AppSpacing.x2),
        TextFormField(
          controller: _newPassCtrl,
          obscureText: _obscureNew,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.inputText.copyWith(color: context.fieldText),
          decoration:
              appInputDecoration(context, 'Enter your new password').copyWith(
            prefixIcon: Icon(
              Icons.lock_reset_outlined,
              size: AppIconSize.md,
              color: context.fieldPlaceholder,
            ),
            suffixIcon: _eyeToggle(
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
          ),
          validator: (value) {
            final base = Validators.password(value);
            if (base != null) return base;
            if (value == _currentPassCtrl.text) {
              return 'New password must differ from current password';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Confirm New Password'),
        const SizedBox(height: AppSpacing.x2),
        TextFormField(
          controller: _confirmPassCtrl,
          obscureText: _obscureConfirm,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          style: AppTextStyles.inputText.copyWith(color: context.fieldText),
          decoration: appInputDecoration(context, 'Re-enter your new password')
              .copyWith(
            prefixIcon: Icon(
              Icons.lock_outline,
              size: AppIconSize.md,
              color: context.fieldPlaceholder,
            ),
            suffixIcon: _eyeToggle(
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          validator: Validators.confirmPassword(_newPassCtrl.text),
        ),
      ],
    );
  }

  // ── Password Hint ─────────────────────────────────────────
  Widget _buildPasswordHint() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x3),
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.fieldBorder.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: AppIconSize.sm,
            color: context.text4,
          ),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Text(
              'Password must be at least 8 characters long.',
              style: AppTextStyles.bodyS.copyWith(color: context.text3),
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit Button → replaced by AppPrimaryButton ────────

  // ── Helpers ───────────────────────────────────────────────
  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelM.copyWith(color: context.text2),
    );
  }

  Widget _eyeToggle({required bool obscure, required VoidCallback onToggle}) {
    return GestureDetector(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3),
        child: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: AppIconSize.md,
          color: context.fieldPlaceholder,
        ),
      ),
    );
  }
}
