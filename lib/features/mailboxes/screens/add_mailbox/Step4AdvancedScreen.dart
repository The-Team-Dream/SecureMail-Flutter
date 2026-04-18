import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/features/mailboxes/providers/mailboxes_provider.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox_shared_widgets.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox/Step5ReviewScreen.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox/step_scaffold.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';

class Step4AdvancedScreen extends ConsumerStatefulWidget {
  const Step4AdvancedScreen({super.key});

  @override
  ConsumerState<Step4AdvancedScreen> createState() =>
      _Step4AdvancedScreenState();
}

class _Step4AdvancedScreenState extends ConsumerState<Step4AdvancedScreen> {
  String _syncFrequency = 'Every 15 minutes';
  final _fetchLimitCtrl = TextEditingController(text: '500');
  bool _securityScan = true;
  bool _restoredFromProvider = false;

  final List<String> _syncOptions = [
    'Every 5 minutes',
    'Every 15 minutes',
    'Every 30 minutes',
    'Every hour',
    'Manual only',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restoredFromProvider) return;

    final existing = ref.read(addMailboxFormProvider);
    if (existing.syncFrequency != null) {
      _syncFrequency = existing.syncFrequency!;
    }
    if (existing.fetchLimit != null) {
      _fetchLimitCtrl.text = existing.fetchLimit.toString();
    }
    _securityScan = existing.securityScanEnabled;
    _restoredFromProvider = true;
  }

  @override
  void dispose() {
    _fetchLimitCtrl.dispose();
    super.dispose();
  }

  void _next() {
    ref.read(addMailboxFormProvider.notifier).updateStep4(
          syncFrequency: _syncFrequency,
          fetchLimit: int.tryParse(_fetchLimitCtrl.text) ?? 500,
          securityScanEnabled: _securityScan,
        );
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const Step5ReviewScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      currentStep: 4,
      title: 'Configuration Details',
      subtitle:
          'Fine-tune how your mailbox handles incoming data and security.',
      onBack: () => Navigator.of(context).pop(),
      onNext: _next,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sync Frequency
          SectionLabel('SYNC FREQUENCY'),
          const SizedBox(height: AppSpacing.x3),
          _buildDropdown(context),
          const SizedBox(height: AppSpacing.itemGap),

          // Fetch Limit
          SectionLabel('INITIAL FETCH LIMIT'),
          const SizedBox(height: AppSpacing.x3),
          TextFormField(
            controller: _fetchLimitCtrl,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyM.copyWith(color: context.text1),
            decoration: stepInputDecoration(context, '500').copyWith(
              suffixText: 'emails',
              suffixStyle:
                  AppTextStyles.bodyS.copyWith(color: context.text3),
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            'MAXIMUM HISTORICAL MESSAGES TO INDEX',
            style: AppTextStyles.caption.copyWith(
              color: context.text3,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.itemGap),

          // Security Scan Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enable Security Scan',
                      style: AppTextStyles.bodyM.copyWith(
                        color: context.text1,
                        fontWeight: FontWeight.w500,
                      )),
                  Text('Scan attachments for potential threats',
                      style: AppTextStyles.bodyS.copyWith(
                        color: context.text3,
                      )),
                ],
              ),
              Switch(
                value: _securityScan,
                onChanged: (v) => setState(() => _securityScan = v),
                activeColor: context.button1,
                activeTrackColor: context.button1.withOpacity(0.3),
                inactiveThumbColor: context.text3,
                inactiveTrackColor: context.fieldBorder,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.itemGap),

          // Info Box
          Container(
            padding: const EdgeInsets.all(AppSpacing.x4),
            decoration: BoxDecoration(
              color: context.fieldBg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.fieldBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: AppIconSize.md, color: context.button1),
                const SizedBox(width: AppSpacing.x3),
                Expanded(
                  child: Text(
                    'Advanced settings can be modified later. Changes to sync frequency may impact battery life on mobile devices.',
                    style:
                        AppTextStyles.bodyS.copyWith(color: context.text3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap * 1.5),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x2,
      ),
      decoration: BoxDecoration(
        color: context.fieldBg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.fieldBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _syncFrequency,
          isExpanded: true,
          dropdownColor: context.card1,
          icon: Icon(Icons.keyboard_arrow_down, color: context.text3),
          style: AppTextStyles.bodyM.copyWith(color: context.text1),
          items: _syncOptions
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _syncFrequency = val);
          },
        ),
      ),
    );
  }
}
