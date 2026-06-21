import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/features/mailboxes/providers/mailboxes_provider.dart';
import 'package:securemail/core/extensions/context_snack_bar.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox/step_scaffold.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';

class Step4ReviewScreen extends ConsumerStatefulWidget {
  const Step4ReviewScreen({super.key});
  @override
  ConsumerState<Step4ReviewScreen> createState() => _Step4ReviewScreenState();
}

class _Step4ReviewScreenState extends ConsumerState<Step4ReviewScreen> {
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final formData = ref.read(addMailboxFormProvider);
      final success = await ref
          .read(mailboxesProvider.notifier)
          .addMailbox(formData);

      if (!mounted) return;
      if (success) {
        ref.read(addMailboxFormProvider.notifier).reset();
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        context.showSnackBar('Failed to connect mailbox', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(addMailboxFormProvider);

    return StepScaffold(
      currentStep: 4,
      totalSteps: 4,
      title: 'Review & Save',
      subtitle: 'Please verify your configuration details before saving.',
      onBack: _isSaving ? () {} : () => Navigator.of(context).pop(),
      onNext: _save,
      nextEnabled: !_isSaving,
      nextLoading: _isSaving,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPaddingH),
            decoration: BoxDecoration(
              color: context.fieldBg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.fieldBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // General Information
                _sectionHeader(context, 'GENERAL INFORMATION'),
                const SizedBox(height: AppSpacing.x4),
                _row(context, 'Account Name', data.displayName ?? '—'),
                const SizedBox(height: AppSpacing.x3),
                _row(context, 'Email Address', data.email ?? '—'),

                _divider(context),

                // IMAP
                _sectionHeader(context, 'INCOMING SERVER (IMAP)'),
                const SizedBox(height: AppSpacing.x4),
                _row(context, 'Host', data.imapHost ?? '—'),
                const SizedBox(height: AppSpacing.x3),
                _row(
                  context,
                  'Port & Encryption',
                  '${data.imapPort ?? "—"} (${data.imapEncryption?.label ?? "None"})',
                ),

                _divider(context),

                // SMTP
                _sectionHeader(context, 'OUTGOING SERVER (SMTP)'),
                const SizedBox(height: AppSpacing.x4),
                _row(context, 'Host', data.smtpHost ?? '—'),
                const SizedBox(height: AppSpacing.x3),
                _row(
                  context,
                  'Port & Encryption',
                  '${data.smtpPort ?? "—"} (${data.smtpEncryption?.label ?? "None"})',
                ),

                _divider(context),

                // Advanced
                _sectionHeader(context, 'ADVANCED SETTINGS'),
                const SizedBox(height: AppSpacing.x4),
                _row(context, 'Sync Frequency',
                    data.syncFrequency ?? 'Every 15 minutes'),
                const SizedBox(height: AppSpacing.x3),
                _row(context, 'Fetch Limit',
                    '${data.fetchLimit ?? 500} emails'),
                const SizedBox(height: AppSpacing.x3),
                _row(context, 'Security Scan',
                    data.securityScanEnabled ? 'Enabled' : 'Disabled'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap * 1.5),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String label) => Text(
        label,
        style: AppTextStyles.labelS.copyWith(
          color: context.button1,
          letterSpacing: 1.5,
        ),
      );

  Widget _row(BuildContext context, String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyS.copyWith(color: context.text3)),
          Flexible(
            child: Text(value,
                style: AppTextStyles.bodyS.copyWith(
                  color: context.text1,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.end),
          ),
        ],
      );

  Widget _divider(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4),
        child: Divider(color: context.fieldBorder, height: 1),
      );
}
