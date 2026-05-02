import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/alerts_provider.dart';
import '../models/alert_model.dart';

class Alertsscreen extends ConsumerWidget {
  const Alertsscreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alertsProvider);
    final alerts = state.filteredAlerts;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFilterChips(context, ref, state.selectedCategory),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => ref.read(alertsProvider.notifier).fetchAlerts(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                        vertical: AppSpacing.screenVertical,
                      ),
                      children: [
                        if (state.selectedCategory == AlertCategory.all || state.selectedCategory == AlertCategory.threats) ...[
                          _buildSectionHeader(context, 'URGENT THREATS', badge: state.criticalCount > 0 ? '${state.criticalCount} CRITICAL' : null),
                          const SizedBox(height: AppSpacing.x4),
                          ...alerts.where((a) => a.category == AlertCategory.threats).map((a) => _buildAlertCard(context, a)),
                          const SizedBox(height: AppSpacing.x8),
                        ],
                        if (state.selectedCategory == AlertCategory.all || state.selectedCategory == AlertCategory.updates || state.selectedCategory == AlertCategory.system) ...[
                          _buildSectionHeader(context, 'SYSTEM UPDATES'),
                          const SizedBox(height: AppSpacing.x4),
                          ...alerts.where((a) => a.category != AlertCategory.threats).map((a) => _buildAlertCard(context, a)),
                        ],
                        const SizedBox(height: AppSpacing.x12),
                      ],
                    ),
                  ),
          ),
        ],
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
        'Notifications',
        style: AppTextStyles.headingL.copyWith(color: context.text1),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_active_outlined, color: context.text1),
          onPressed: () => context.push(AppRoutes.notificationsSettings),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context, WidgetRef ref, AlertCategory selected) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        children: AlertCategory.values.map((cat) {
          final isSelected = selected == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(cat.name[0].toUpperCase() + cat.name.substring(1).replaceAll('all', 'All Alerts')),
              selected: isSelected,
              onSelected: (_) => ref.read(alertsProvider.notifier).setCategory(cat),
              backgroundColor: context.card1,
              selectedColor: context.button1,
              labelStyle: AppTextStyles.labelM.copyWith(
                color: isSelected ? Colors.white : context.text1,
              ),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                side: BorderSide(color: isSelected ? context.button1 : context.fieldBorder.withOpacity(0.3)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {String? badge}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.labelS.copyWith(
            color: context.text3,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.danger.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              badge,
              style: AppTextStyles.labelS.copyWith(
                color: context.danger,
                fontWeight: FontWeight.w900,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAlertCard(BuildContext context, AlertNotification alert) {
    final Color severityColor;
    switch (alert.severity) {
      case AlertSeverity.critical:
        severityColor = context.danger;
        break;
      case AlertSeverity.high:
        severityColor = context.warning;
        break;
      case AlertSeverity.medium:
        severityColor = context.warning.withOpacity(0.8);
        break;
      default:
        severityColor = context.success;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x4),
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Side Indicator
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: severityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xxl),
                  bottomLeft: Radius.circular(AppRadius.xxl),
                ),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildIconBox(context, alert.icon, severityColor),
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
                                      alert.title,
                                      style: AppTextStyles.headingS.copyWith(
                                        color: context.text1,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    timeago.format(alert.timestamp, locale: 'en_short') + ' ago',
                                    style: AppTextStyles.bodyS.copyWith(color: context.text3),
                                  ),
                                  if (!alert.isRead) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                          color: context.info,
                                          shape: BoxShape.circle),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                alert.description,
                                style: AppTextStyles.bodyM.copyWith(color: context.text3.withOpacity(0.9), height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    if (alert.actions != null) ...[
                      const SizedBox(height: AppSpacing.x4),
                      Row(
                        children: alert.actions!.map((action) {
                          final isDanger = action.toLowerCase().contains('password');
                          return Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: InkWell(
                              onTap: () {},
                              child: Text(
                                action,
                                style: AppTextStyles.labelM.copyWith(
                                  color: isDanger
                                      ? context.info
                                      : context.text1.withOpacity(0.7),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox(BuildContext context, IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
