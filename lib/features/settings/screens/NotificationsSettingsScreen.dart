import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/shared/widgets/app_primary_button.dart';
import 'package:securemail/shared/widgets/auth_gradient_background.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  // ── Push Notifications ────────────────────────────────────
  bool _newLoginDetected = true;
  bool _weeklySecurityReport = true;
  bool _lowMailboxSpace = true;

  // ── Email Notifications ───────────────────────────────────
  bool _newsletterAndUpdates = true;
  bool _failedDeliveryReports = true;

  // ── Security Alerts ───────────────────────────────────────
  bool _passwordChangeAlerts = true;
  bool _unusualActivityDetected = true;
  bool _twoFactorRecoveryUsed = true;

  bool _isLoading = false;

  Future<void> _savePreferences() async {
    setState(() => _isLoading = true);

    // TODO: استبدل بـ API call حقيقي
    // await ApiClient.instance.patch(
    //   ApiConstants.notificationSettings,
    //   data: {
    //     'pushNotifications': {
    //       'newLoginDetected': _newLoginDetected,
    //       'weeklySecurityReport': _weeklySecurityReport,
    //       'lowMailboxSpace': _lowMailboxSpace,
    //     },
    //     'emailNotifications': {
    //       'newsletterAndUpdates': _newsletterAndUpdates,
    //       'failedDeliveryReports': _failedDeliveryReports,
    //     },
    //     'securityAlerts': {
    //       'passwordChangeAlerts': _passwordChangeAlerts,
    //       'unusualActivityDetected': _unusualActivityDetected,
    //       'twoFactorRecoveryUsed': _twoFactorRecoveryUsed,
    //     },
    //   },
    // );

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Preferences saved successfully.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.x2),

                      // ── Push Notifications ───────────────
                      _buildSectionLabel('PUSH NOTIFICATIONS'),
                      const SizedBox(height: AppSpacing.x2),
                      _buildCard(children: [
                        _buildToggle(
                          label: 'New login detected',
                          value: _newLoginDetected,
                          onChanged: (v) =>
                              setState(() => _newLoginDetected = v),
                          showDivider: true,
                        ),
                        _buildToggle(
                          label: 'Weekly security report',
                          value: _weeklySecurityReport,
                          onChanged: (v) =>
                              setState(() => _weeklySecurityReport = v),
                          showDivider: true,
                        ),
                        _buildToggle(
                          label: 'Low mailbox space',
                          value: _lowMailboxSpace,
                          onChanged: (v) =>
                              setState(() => _lowMailboxSpace = v),
                          showDivider: false,
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.x6),

                      // ── Email Notifications ──────────────
                      _buildSectionLabel('EMAIL NOTIFICATIONS'),
                      const SizedBox(height: AppSpacing.x2),
                      _buildCard(children: [
                        _buildToggle(
                          label: 'Newsletter and Updates',
                          value: _newsletterAndUpdates,
                          onChanged: (v) =>
                              setState(() => _newsletterAndUpdates = v),
                          showDivider: true,
                        ),
                        _buildToggle(
                          label: 'Failed delivery reports',
                          value: _failedDeliveryReports,
                          onChanged: (v) =>
                              setState(() => _failedDeliveryReports = v),
                          showDivider: false,
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.x6),

                      // ── Security Alerts ──────────────────
                      _buildSectionLabel('SECURITY ALERTS'),
                      const SizedBox(height: AppSpacing.x2),
                      _buildCard(children: [
                        _buildToggle(
                          label: 'Password change alerts',
                          value: _passwordChangeAlerts,
                          onChanged: (v) =>
                              setState(() => _passwordChangeAlerts = v),
                          showDivider: true,
                        ),
                        _buildToggle(
                          label: 'Unusual activity detected',
                          value: _unusualActivityDetected,
                          onChanged: (v) =>
                              setState(() => _unusualActivityDetected = v),
                          showDivider: true,
                        ),
                        _buildToggle(
                          label: 'Two-factor recovery used',
                          value: _twoFactorRecoveryUsed,
                          onChanged: (v) =>
                              setState(() => _twoFactorRecoveryUsed = v),
                          showDivider: false,
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.x8),

                      // ── Save Button ──────────────────────
                      AppPrimaryButton(
                        label: 'Save Preferences',
                        onPressed: _savePreferences,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: AppSpacing.x3),

                      // ── Note ────────────────────────────
                      Center(
                        child: Text(
                          'Changes may take up to 5 minutes to reflect across all devices.',
                          style: AppTextStyles.bodyS
                              .copyWith(color: context.text3),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x8),

                      // ── Footer ───────────────────────────
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_outlined,
                                size: 14, color: context.text3),
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
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelS.copyWith(
        color: context.text3,
        letterSpacing: 1.5,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: context.fieldBorder.withOpacity(0.3)),
      ),
      child: Column(children: children),
    );
  }

  // ── Toggle Row ────────────────────────────────────────────
  Widget _buildToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x4,
            vertical: AppSpacing.x3,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyM.copyWith(
                    color: context.text1,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: context.button1,
                activeTrackColor: context.button2.withOpacity(0.3),
                inactiveThumbColor: context.text3,
                inactiveTrackColor: context.card2,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: context.fieldBorder.withOpacity(0.3),
            height: 1,
            indent: AppSpacing.x4,
            endIndent: AppSpacing.x4,
          ),
      ],
    );
  }
}
