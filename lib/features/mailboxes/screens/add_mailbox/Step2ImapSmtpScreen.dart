import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/enums/encryption_mode.dart';
import 'package:securemail/features/mailboxes/providers/mailboxes_provider.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox_shared_widgets.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox/Step3AdvancedScreen.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox/step_scaffold.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';

class Step2ImapSmtpScreen extends ConsumerStatefulWidget {
  const Step2ImapSmtpScreen({super.key});
  @override
  ConsumerState<Step2ImapSmtpScreen> createState() =>
      _Step2ImapSmtpScreenState();
}

class _Step2ImapSmtpScreenState extends ConsumerState<Step2ImapSmtpScreen> {
  final _formKey = GlobalKey<FormState>();

  // IMAP
  final _imapHostCtrl = TextEditingController();
  final _imapPortCtrl = TextEditingController(text: '993');

  // SMTP
  final _smtpHostCtrl = TextEditingController();
  final _smtpPortCtrl = TextEditingController(text: '465');

  // Shared
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  EncryptionMode _encryption = EncryptionMode.sslTls;
  bool _obscurePass = true;
  bool _restoredFromProvider = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restoredFromProvider) return;

    final existing = ref.read(addMailboxFormProvider);
    if (existing.imapHost != null) _imapHostCtrl.text = existing.imapHost!;
    if (existing.imapPort != null) {
      _imapPortCtrl.text = existing.imapPort.toString();
    }
    if (existing.smtpHost != null) _smtpHostCtrl.text = existing.smtpHost!;
    if (existing.smtpPort != null) {
      _smtpPortCtrl.text = existing.smtpPort.toString();
    }
    if (existing.email != null) _emailCtrl.text = existing.email!;
    if (existing.imapEncryption != null) {
      _encryption = existing.imapEncryption!;
    }
    _restoredFromProvider = true;
  }

  @override
  void dispose() {
    _imapHostCtrl.dispose();
    _imapPortCtrl.dispose();
    _smtpHostCtrl.dispose();
    _smtpPortCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(addMailboxFormProvider.notifier).updateStep2(
          email: _emailCtrl.text.trim(),
          imapHost: _imapHostCtrl.text.trim(),
          imapPort: int.tryParse(_imapPortCtrl.text) ?? 993,
          imapEncryption: _encryption,
          imapPassword: _passCtrl.text,
          smtpHost: _smtpHostCtrl.text.trim(),
          smtpPort: int.tryParse(_smtpPortCtrl.text) ?? 465,
          smtpEncryption: _encryption,
          smtpPassword: _passCtrl.text,
        );

    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const Step3AdvancedScreen()));
  }

  String? _portValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final port = int.tryParse(v);
    if (port == null) return 'Must be a number';
    if (port < 1 || port > 65535) return 'Port must be 1–65535';
    return null;
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
    return null;
  }

  Widget _sectionHeader(BuildContext context, String label, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.button1.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: AppIconSize.sm, color: context.button1),
        ),
        const SizedBox(width: AppSpacing.x3),
        Text(
          label,
          style: AppTextStyles.labelM.copyWith(
            color: context.button1,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _rowInputs({
    required BuildContext context,
    required String leftLabel,
    required TextEditingController leftCtrl,
    required String leftHint,
    required String rightLabel,
    required TextEditingController rightCtrl,
    required String rightHint,
    required String? Function(String?) rightValidator,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(leftLabel),
              const SizedBox(height: AppSpacing.x3),
              TextFormField(
                controller: leftCtrl,
                style: AppTextStyles.bodyM.copyWith(color: context.text1),
                decoration: stepInputDecoration(context, leftHint),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(rightLabel),
              const SizedBox(height: AppSpacing.x3),
              TextFormField(
                controller: rightCtrl,
                keyboardType: TextInputType.number,
                style: AppTextStyles.bodyM.copyWith(color: context.text1),
                decoration: stepInputDecoration(context, rightHint),
                validator: rightValidator,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      currentStep: 2,
      totalSteps: 4,
      title: 'IMAP / SMTP',
      subtitle: 'Configure your incoming and outgoing mail servers.',
      onBack: () => Navigator.of(context).pop(),
      onNext: _next,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── IMAP Section ────────────────────────────────────
            _sectionHeader(context, 'INCOMING SERVER (IMAP)',
                Icons.download_rounded),
            const SizedBox(height: AppSpacing.x4),

            _rowInputs(
              context: context,
              leftLabel: 'IMAP HOST',
              leftCtrl: _imapHostCtrl,
              leftHint: 'imap.example.com',
              rightLabel: 'PORT',
              rightCtrl: _imapPortCtrl,
              rightHint: '993',
              rightValidator: _portValidator,
            ),
            const SizedBox(height: AppSpacing.itemGap),

            // ── SMTP Section ────────────────────────────────────
            _sectionHeader(context, 'OUTGOING SERVER (SMTP)',
                Icons.upload_rounded),
            const SizedBox(height: AppSpacing.x4),

            _rowInputs(
              context: context,
              leftLabel: 'SMTP HOST',
              leftCtrl: _smtpHostCtrl,
              leftHint: 'smtp.example.com',
              rightLabel: 'PORT',
              rightCtrl: _smtpPortCtrl,
              rightHint: '465',
              rightValidator: _portValidator,
            ),
            const SizedBox(height: AppSpacing.itemGap),

            // ── Security ────────────────────────────────────────
            _sectionHeader(context, 'SECURITY', Icons.shield_outlined),
            const SizedBox(height: AppSpacing.x4),

            SectionLabel('ENCRYPTION'),
            const SizedBox(height: AppSpacing.x3),
            EncryptionToggle<EncryptionMode>(
              values: EncryptionMode.values,
              selected: _encryption,
              labels: {
                EncryptionMode.none: EncryptionMode.none.label,
                EncryptionMode.sslTls: EncryptionMode.sslTls.label,
                EncryptionMode.startTls: EncryptionMode.startTls.label,
              },
              onChanged: (v) => setState(() => _encryption = v),
            ),
            const SizedBox(height: AppSpacing.itemGap),

            // ── Credentials ─────────────────────────────────────
            _sectionHeader(context, 'CREDENTIALS', Icons.key_rounded),
            const SizedBox(height: AppSpacing.x4),

            SectionLabel('EMAIL / USERNAME'),
            const SizedBox(height: AppSpacing.x3),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: AppTextStyles.bodyM.copyWith(color: context.text1),
              decoration: stepInputDecoration(
                context,
                'user@domain.com',
                prefix: Icon(Icons.person_outline,
                    size: AppIconSize.md, color: context.text3),
              ),
              validator: _emailValidator,
            ),
            const SizedBox(height: AppSpacing.itemGap),

            SectionLabel('APP PASSWORD'),
            const SizedBox(height: AppSpacing.x3),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              style: AppTextStyles.bodyM.copyWith(color: context.text1),
              decoration: stepInputDecoration(
                context,
                '••••••••••••',
                prefix: Icon(Icons.lock_outline,
                    size: AppIconSize.md, color: context.text3),
                suffix: GestureDetector(
                  onTap: () =>
                      setState(() => _obscurePass = !_obscurePass),
                  child: Icon(
                    _obscurePass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: AppIconSize.md,
                    color: context.text3,
                  ),
                ),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.sectionGap * 1.5),
          ],
        ),
      ),
    );
  }
}
