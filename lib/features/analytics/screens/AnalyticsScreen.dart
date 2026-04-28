import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';

class Analyticsscreen extends StatelessWidget {
  const Analyticsscreen({super.key});

  static const _background = Color(0xFF03110D);
  static const _panel = Color(0xFF0B241D);
  static const _accent = Color(0xFF2EC4A6);
  static const _text = Color(0xFFE8F6F2);
  static const _muted = Color(0xFF91BDB4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              'Analytics',
              style: AppTextStyles.displayS.copyWith(
                color: _text,
                fontSize: 24,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 18),
            const _MetricCard(
              label: 'Threats Blocked',
              value: '47',
              icon: Icons.shield_outlined,
            ),
            const _MetricCard(
              label: 'Clean Emails',
              value: '1,201',
              icon: Icons.mark_email_read_outlined,
            ),
            const _MetricCard(
              label: 'System Health',
              value: '98%',
              icon: Icons.monitor_heart_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Analyticsscreen._panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Analyticsscreen._accent.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Analyticsscreen._accent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyM.copyWith(
                color: Analyticsscreen._muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.displayS.copyWith(
              color: Analyticsscreen._text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
