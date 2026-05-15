import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/features/mailbox_detail/models/security_report_model.dart';
import 'package:securemail/features/mailbox_detail/providers/messages_provider.dart';

class SecurityReportScreen extends ConsumerStatefulWidget {
  const SecurityReportScreen({
    super.key,
    required this.incidentId,
    required this.mailboxId,
  });

  final String incidentId;
  final int mailboxId;

  @override
  ConsumerState<SecurityReportScreen> createState() => _SecurityReportScreenState();
}

class _SecurityReportScreenState extends ConsumerState<SecurityReportScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final emailId = int.tryParse(widget.incidentId);
      if (emailId == null) {
        throw Exception('Invalid incident ID');
      }
      
      await ref.read(messagesProvider.notifier).fetchEmailDetail(widget.mailboxId, emailId);
      
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  Widget _buildBody(BuildContext context) {
    final state = ref.watch(messagesProvider);
    final reportMap = state.selectedEmail?.securityReport;
    final report = reportMap != null ? SecurityReportModel.fromJson(reportMap) : null;

    if (_loading) {
      return Center(child: CircularProgressIndicator(color: context.button1));
    }
    if (_error != null || report == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: const Color(0xFFFF5252), size: 48),
            const SizedBox(height: 16),
            Text(_error ?? 'No security report available for this email.',
                style: AppTextStyles.bodyM.copyWith(color: context.text1)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchReport,
              style: ElevatedButton.styleFrom(backgroundColor: context.button1),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _buildMaliciousHeader(context, report),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'THREAT DETAILS'),
        const SizedBox(height: 12),
        _buildThreatDetailsCard(context, report),
        const SizedBox(height: 16),
        _buildRecommendationCard(context, report),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'SUGGESTED ACTIONS'),
        const SizedBox(height: 12),
        _buildSuggestedActions(context, report),
        const SizedBox(height: 24),
        ...report.anomalies
            .map((anomaly) => _buildAnomalyCard(context, anomaly))
            .toList(),
        const SizedBox(height: 32),
        _buildFooter(context, report),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: context.button1, size: 22),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Security Report',
              style: AppTextStyles.bodyL.copyWith(
                color: context.button1,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.shield, color: context.button1, size: 18),
          ],
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.labelS.copyWith(
        color: context.text3,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildMaliciousHeader(
      BuildContext context, SecurityReportModel report) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.securityReport,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.pest_control_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 8),
          Text(
            report.status,
            style: AppTextStyles.displayS.copyWith(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.securityReport2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOW SURE ARE WE?',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: report.confidenceScore / 100,
                          minHeight: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${report.confidenceScore}%',
                      style: AppTextStyles.bodyS.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            report.detectionMessage,
            style: AppTextStyles.bodyS.copyWith(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return const Color(0xFF4CAF50);
      case 'medium':
        return const Color(0xFFF39C12);
      case 'high':
        return const Color(0xFFFF5252);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Widget _buildThreatDetailsCard(
      BuildContext context, SecurityReportModel report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.button1.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.button1.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(context, 'Severity', report.severity,
              _getColorForLevel(report.severity)),
          const SizedBox(height: 12),
          _buildDetailRow(context, 'Priority', report.priority,
              _getColorForLevel(report.priority)),
          const SizedBox(height: 16),
          Text(
            'Reason: ${report.reason}',
            style: AppTextStyles.bodyS.copyWith(
              color: context.text1,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            report.description,
            style: AppTextStyles.bodyS.copyWith(
              color: context.text2,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyS.copyWith(
            color: context.text2,
            fontSize: 12,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            value,
            style: AppTextStyles.labelS.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, SecurityReportModel report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.securityReport3,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.recommendationTitle,
                  style: AppTextStyles.bodyM.copyWith(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  report.recommendationText,
                  style: AppTextStyles.bodyS.copyWith(
                    color: const Color(0xFF1B5E20).withValues(alpha: 0.8),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedActions(
      BuildContext context, SecurityReportModel report) {
    return Row(
      children: report.suggestedActions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        final isPrimary = index == 0;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: index != report.suggestedActions.length - 1 ? 8.0 : 0.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isPrimary
                    ? context.button1
                    : context.button1.withValues(alpha: 0.1),
                foregroundColor: isPrimary ? Colors.white : context.button1,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                action,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyS.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnomalyCard(
      BuildContext context, SecurityReportAnomaly anomaly) {
    final isWarning = anomaly.type == 'warning';
    final color = isWarning ? const Color(0xFFF39C12) : const Color(0xFFE54D4D);
    final icon =
        isWarning ? Icons.warning_amber_rounded : Icons.track_changes_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  anomaly.title,
                  style: AppTextStyles.bodyM.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  anomaly.description,
                  style: AppTextStyles.bodyS.copyWith(
                    color: context.text2,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, SecurityReportModel report) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield,
                color: context.text3.withValues(alpha: 0.5), size: 14),
            const SizedBox(width: 6),
            Text(
              'Analysis powered by ${report.analysisEngine}',
              style: AppTextStyles.caption.copyWith(
                color: context.text3.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Report generated for email ID: ${report.emailId}',
          style: AppTextStyles.caption.copyWith(
            color: context.text3.withValues(alpha: 0.4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
