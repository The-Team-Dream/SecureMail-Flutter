import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/network/api_client.dart';
import 'package:securemail/core/constants/ApiConstants.dart';

class SecurityReportModel {
  final int id;
  final String subject;
  final String from;
  final String fromName;
  final String date;
  final String classification;
  final String classificationReason;
  final double classificationScore;
  final String? malwareVerdict;
  final double? malwareScore;
  final String? malwareSeverity;
  final Map<String, dynamic>? aiReport;

  SecurityReportModel({
    required this.id,
    required this.subject,
    required this.from,
    required this.fromName,
    required this.date,
    required this.classification,
    required this.classificationReason,
    required this.classificationScore,
    this.malwareVerdict,
    this.malwareScore,
    this.malwareSeverity,
    this.aiReport,
  });

  factory SecurityReportModel.fromJson(Map<String, dynamic> json) {
    return SecurityReportModel(
      id:                   json['id'] as int,
      subject:              json['subject'] as String? ?? '',
      from:                 json['from'] as String? ?? '',
      fromName:             json['fromName'] as String? ?? '',
      date:                 json['date'] as String? ?? '',
      classification:       json['classification'] as String? ?? 'unknown',
      classificationReason: json['classificationReason'] as String? ?? '',
      classificationScore:  (json['classificationScore'] ?? 0).toDouble(),
      malwareVerdict:       json['malwareVerdict'] as String?,
      malwareScore:         (json['malwareScore'] ?? 0).toDouble(),
      malwareSeverity:      json['malwareSeverity'] as String?,
      aiReport:             json['aiReport'] as Map<String, dynamic>?,
    );
  }
}

final securityReportsProvider = FutureProvider.family<List<SecurityReportModel>, int>((ref, mailboxId) async {
  final response = await ApiClient.get(ApiConstants.mailboxReports(mailboxId));
  final List<dynamic> data = response.data['data'];
  return data.map((r) => SecurityReportModel.fromJson(r)).toList();
});
