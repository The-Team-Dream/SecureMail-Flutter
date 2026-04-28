import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';

class Alertsscreen extends StatelessWidget {
  const Alertsscreen({super.key});

  static const _background = Color(0xFF03110D);
  static const _panel = Color(0xFF0B241D);
  static const _accent = Color(0xFF2EC4A6);
  static const _danger = Color(0xFFFF5252);
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
              'Alerts',
              style: AppTextStyles.displayS.copyWith(
                color: _text,
                fontSize: 24,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 18),
            const _AlertTile(
              title: 'Phishing Email Detected',
              message: 'A suspicious login email was isolated.',
              color: _danger,
              icon: Icons.phishing_outlined,
            ),
            const _AlertTile(
              title: 'New Login Detected',
              message: 'Windows Edge session from a new location.',
              color: _accent,
              icon: Icons.devices_outlined,
            ),
            const _AlertTile(
              title: 'Weekly Security Report',
              message: 'Your mailbox report is ready to review.',
              color: _accent,
              icon: Icons.analytics_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
  });

  final String title;
  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Alertsscreen._panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyM.copyWith(
                    color: Alertsscreen._text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.bodyS.copyWith(
                    color: Alertsscreen._muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
