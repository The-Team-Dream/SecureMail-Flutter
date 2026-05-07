import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_provider.dart';
import '../models/analytics_model.dart';

class Analyticsscreen extends ConsumerWidget {
  const Analyticsscreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(analyticsOverviewProvider);
    final activityAsync = ref.watch(analyticsActivityProvider('weekly'));

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: _buildAppBar(context),
      body: overviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (overview) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(analyticsOverviewProvider);
            ref.invalidate(analyticsActivityProvider('weekly'));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.screenVertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Cards (إعادة المسميات الأصلية مع ربط القيم)
                _buildMetricCard(
                  context: context,
                  title: 'TOTAL THREATS BLOCKED',
                  value: NumberFormat('#,###').format(overview.totalPhishingDetected + overview.totalSpamDetected),
                  change: '+12%', // قيمة افتراضية للحفاظ على التصميم
                  subtitle: 'Comparison vs previous 30 days',
                  icon: Icons.shield_outlined,
                  isPositive: true,
                ),
                const SizedBox(height: AppSpacing.x3),
                _buildMetricCard(
                  context: context,
                  title: 'CRITICAL ALERTS',
                  value: overview.totalPhishingDetected.toString(),
                  change: '-5%', // قيمة افتراضية للحفاظ على التصميم
                  subtitle: 'Active incidents requiring attention',
                  icon: Icons.warning_amber_rounded,
                  isPositive: true,
                  iconColor: Colors.redAccent,
                ),
                const SizedBox(height: AppSpacing.x3),
                _buildHealthCard(context, overview),

                const SizedBox(height: AppSpacing.x8),
                activityAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading activity: $e'),
                  data: (activity) => _buildWeeklyDistribution(context, activity),
                ),

                const SizedBox(height: AppSpacing.x8),
                _buildRecentEventsHeader(context),
                const SizedBox(height: AppSpacing.x3),
                // إعادة استخدام الموديلات الأصلية لضمان عدم تغيير منطق الواجهة
                _buildEventItem(context, SecurityEvent(
                  title: 'Suspicious Login',
                  description: 'New IP detected in USA',
                  severity: EventSeverity.high,
                  icon: Icons.security,
                  timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
                )),
                _buildEventItem(context, SecurityEvent(
                  title: 'Mailbox Sync',
                  description: 'Successfully synced 42 emails',
                  severity: EventSeverity.info,
                  icon: Icons.sync,
                  timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
                )),
                
                const SizedBox(height: AppSpacing.x8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // Components
  // ══════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.bgColor,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.text1),
        onPressed: () => Navigator.maybePop(context),
      ),
      title: Text(
        'Analytics',
        style: AppTextStyles.headingL.copyWith(color: context.text1),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.bar_chart_rounded, color: context.text1),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.headingM.copyWith(
        color: context.text1,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String change,
    required String subtitle,
    required IconData icon,
    required bool isPositive,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x5),
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: context.fieldBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.labelS.copyWith(
                  color: context.button1.withOpacity(0.8),
                  letterSpacing: 1.2,
                ),
              ),
              Icon(icon, color: iconColor ?? context.button1, size: 24),
            ],
          ),
          const SizedBox(height: AppSpacing.x3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTextStyles.displayS.copyWith(
                  color: context.text1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              Text(
                change,
                style: AppTextStyles.labelM.copyWith(
                  color: isPositive ? context.danger : context.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            subtitle,
            style: AppTextStyles.bodyS.copyWith(color: context.text3),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard(BuildContext context, AnalyticsOverviewModel data) {
    // حساب تقريبي لصحة النظام بناءً على نسبة الإيميلات السليمة
    final total = data.totalEmails > 0 ? data.totalEmails : 1;
    final threats = data.totalPhishingDetected + data.totalSpamDetected;
    final healthScore = (((total - threats) / total) * 100).toInt().clamp(0, 100);
    final status = healthScore > 90 ? 'EXCELLENT' : healthScore > 70 ? 'GOOD' : 'WARNING';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.x5),
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: context.fieldBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SYSTEM HEALTH',
                style: AppTextStyles.labelS.copyWith(
                  color: context.button1.withOpacity(0.8),
                  letterSpacing: 1.2,
                ),
              ),
              Icon(Icons.query_stats_rounded, color: context.button1, size: 24),
            ],
          ),
          const SizedBox(height: AppSpacing.x3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$healthScore%',
                style: AppTextStyles.displayS.copyWith(
                  color: context.text1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: AppSpacing.x2),
              Text(
                status,
                style: AppTextStyles.labelM.copyWith(
                  color: healthScore > 70 ? context.success : context.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: healthScore / 100,
              minHeight: 6,
              backgroundColor: context.card2,
              valueColor: AlwaysStoppedAnimation<Color>(
                healthScore > 70 ? context.success : context.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDistribution(BuildContext context, List<ActivityDataPoint> data) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.x5),
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: context.fieldBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Activity Distribution',
            style: AppTextStyles.headingS.copyWith(
              color: context.text1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.x6),
          
          // Chart based on real activity data
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final total = item.received + item.sent;
                final height = (total * 2.0).clamp(10.0, 100.0);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 12,
                      height: height,
                      decoration: BoxDecoration(
                        color: item.phishing > 0 ? context.danger : context.button1,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x2),
                    Text(
                      item.date.split('-').last, // Show day part
                      style: AppTextStyles.labelS.copyWith(
                        color: context.text3,
                        fontSize: 9,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: AppSpacing.x6),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.x4),
          
          Row(
            children: [
              _buildLegendItem(context, 'Safe Traffic', 'Regular activity', context.button1),
              const Spacer(),
              _buildLegendItem(context, 'Threat Detected', 'Security risk', context.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.x2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.bodyS.copyWith(color: context.text3, fontSize: 11)),
            Text(value, style: AppTextStyles.labelS.copyWith(color: context.text1, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentEventsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Recent Security Events',
          style: AppTextStyles.headingS.copyWith(
            color: context.text1,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'View All',
            style: AppTextStyles.labelM.copyWith(color: context.button1),
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem(BuildContext context, SecurityEvent event) {
    final Color severityColor;
    switch (event.severity) {
      case EventSeverity.high:
        severityColor = Colors.redAccent;
        break;
      case EventSeverity.medium:
        severityColor = Colors.orangeAccent;
        break;
      case EventSeverity.info:
        severityColor = Colors.greenAccent;
        break;
      default:
        severityColor = context.text3;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x3),
      padding: const EdgeInsets.all(AppSpacing.x4),
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: context.fieldBorder.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.x2),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(event.icon, color: severityColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyM.copyWith(
                          color: context.text1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      event.severity.name.toUpperCase(),
                      style: AppTextStyles.labelS.copyWith(
                        color: severityColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  event.description,
                  style: AppTextStyles.bodyS.copyWith(color: context.text3),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat.jm().format(event.timestamp)} ago',
                  style: AppTextStyles.labelS.copyWith(color: context.text3.withOpacity(0.7), fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Models مفقودة لإصلاح الخطأ ─────────────────────────────

enum EventSeverity { high, medium, info }

class SecurityEvent {
  final String title;
  final String description;
  final EventSeverity severity;
  final IconData icon;
  final DateTime timestamp;

  SecurityEvent({
    required this.title,
    required this.description,
    required this.severity,
    required this.icon,
    required this.timestamp,
  });
}
