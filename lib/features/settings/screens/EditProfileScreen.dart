import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/utils/validators.dart';
import 'package:securemail/features/auth/providers/profile_provider.dart';
import 'package:securemail/shared/widgets/app_border_outline.dart';
import 'package:securemail/shared/widgets/app_primary_button.dart';
import 'package:securemail/shared/widgets/auth_gradient_background.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _isLoading = false;

  // ── القيم الأصلية عشان نرجعلها لو discard ─────────────────
  String _originalName = '';
  String _originalEmail = '';

  @override
  void initState() {
    super.initState();
    // ← اشحن من الـ provider مش hardcoded
    final profile = ref.read(profileProvider).profile;
    _nameCtrl.text = profile?.username ?? '';
    _emailCtrl.text = profile?.email ?? '';
    _originalName = profile?.username ?? '';
    _originalEmail = profile?.email ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: استبدل بـ API call حقيقي
    // await ApiClient.instance.patch(
    //   ApiConstants.updateProfile,
    //   data: {'username': _nameCtrl.text.trim()},
    // );

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    // ← السطر المهم: بيحدث ProfileScreen تلقائياً
    await ref.read(profileProvider.notifier).refresh();

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile updated successfully.',
          style: AppTextStyles.bodyM.copyWith(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F8A70),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  void _discard() {
    // ← ارجع للبيانات الأصلية من الـ provider
    _nameCtrl.text = _originalName;
    _emailCtrl.text = _originalEmail;
    _phoneCtrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: AuthGradientBackground(
        child: SafeArea(
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.x4),

                    // ── Avatar ──────────────────────────────
                    _buildAvatar(),
                    const SizedBox(height: AppSpacing.x3),

                    // ── User Info ───────────────────────────
                    Text(
                      _nameCtrl.text,
                      style:
                          AppTextStyles.headingL.copyWith(color: context.text1),
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    Text(
                      _emailCtrl.text,
                      style: AppTextStyles.bodyM.copyWith(color: context.text3),
                    ),
                    const SizedBox(height: AppSpacing.x8),

                    // ── Full Name ───────────────────────────
                    _buildFieldLabel('Full Name'),
                    const SizedBox(height: AppSpacing.x2),
                    TextFormField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      style: AppTextStyles.inputText
                          .copyWith(color: context.fieldText),
                      decoration: appInputDecoration(context, 'Full Name'),
                      validator: Validators.name,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: AppSpacing.x4),

                    // ── Email Address ───────────────────────
                    _buildFieldLabel('Email Address'),
                    const SizedBox(height: AppSpacing.x2),
                    TextFormField(
                      controller: _emailCtrl,
                      enabled: false,
                      style: AppTextStyles.inputText
                          .copyWith(color: context.fieldText.withOpacity(0.5)),
                      decoration:
                          appInputDecoration(context, 'Email Address').copyWith(
                        fillColor: context.fieldBg.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 12, color: context.text3),
                        const SizedBox(width: 4),
                        Text(
                          'Email cannot be changed for security reasons.',
                          style: AppTextStyles.caption
                              .copyWith(color: context.text3),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x4),

                    // ── Phone Number ────────────────────────
                    _buildFieldLabel('Phone Number'),
                    const SizedBox(height: AppSpacing.x2),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      style: AppTextStyles.inputText
                          .copyWith(color: context.fieldText),
                      decoration: appInputDecoration(context, 'Phone Number'),
                    ),
                    const SizedBox(height: AppSpacing.x8),

                    // ── Save Button ─────────────────────────
                    AppPrimaryButton(
                      label: 'Save Changes',
                      onPressed: _save,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppSpacing.x3),

                    // ── Discard Button ──────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: AppSize.buttonHeightL,
                      child: OutlinedButton(
                        onPressed: _discard,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.button1,
                          side: BorderSide(color: context.button1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: Text(
                          'Discard Changes',
                          style: AppTextStyles.labelL
                              .copyWith(color: context.button1),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x8),

                    // ── Footer ──────────────────────────────
                    _buildFooter(),
                    const SizedBox(height: AppSpacing.x4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Avatar ─────────────────────────────────────────────────
  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.button1.withOpacity(0.4),
              width: 2,
            ),
            color: context.card2,
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: context.card2,
            child: Icon(Icons.person, size: 56, color: context.button1),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: context.button1,
              shape: BoxShape.circle,
              border: Border.all(color: context.bgColor, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: AppTextStyles.labelM.copyWith(color: context.text2),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, size: 14, color: context.text3),
        const SizedBox(width: AppSpacing.x1),
        Text(
          'SECUREMAIL',
          style: AppTextStyles.labelS.copyWith(
            color: context.text3,
            letterSpacing: 2,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
