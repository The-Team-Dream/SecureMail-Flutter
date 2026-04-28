import 'package:flutter/material.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_side_drawer.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      drawer: const MailboxSideDrawer(activeRoute: AppRoutes.reports),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: context.barBg,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              child: Row(
                children: [
                  Builder(
                    builder: (scaffoldContext) {
                      return IconButton(
                        onPressed: () =>
                            Scaffold.of(scaffoldContext).openDrawer(),
                        icon: Icon(Icons.menu_rounded, color: context.text1),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Reports',
                    style: AppTextStyles.displayS.copyWith(
                      color: context.text1,
                      fontSize: 24,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: const [
                  _ReportCard(
                    label: 'Threats Blocked',
                    value: '47',
                    icon: Icons.shield_outlined,
                  ),
                  _ReportCard(
                    label: 'Phishing Attempts',
                    value: '23',
                    icon: Icons.phishing_outlined,
                  ),
                  _ReportCard(
                    label: 'Clean Messages',
                    value: '1,201',
                    icon: Icons.verified_outlined,
                  ),
                  _ReportCard(
                    label: 'System Health',
                    value: '98%',
                    icon: Icons.monitor_heart_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
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
        color: context.card1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.button1.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.button1.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: context.button1),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyM.copyWith(
                color: context.text2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.displayS.copyWith(
              color: context.text1,
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
