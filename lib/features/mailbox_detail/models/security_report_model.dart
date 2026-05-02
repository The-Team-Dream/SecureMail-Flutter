class SecurityReportAnomaly {
  final String type;
  final String title;
  final String description;

  const SecurityReportAnomaly({
    required this.type,
    required this.title,
    required this.description,
  });

  factory SecurityReportAnomaly.fromJson(Map<String, dynamic> json) {
    return SecurityReportAnomaly(
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

class SecurityReportModel {
  final String status;
  final int confidenceScore;
  final String detectionMessage;
  
  final String severity;
  final String priority;
  final String reason;
  final String description;

  final String recommendationTitle;
  final String recommendationText;

  final List<String> suggestedActions;
  final List<SecurityReportAnomaly> anomalies;

  final String emailId;
  final String analysisEngine;

  const SecurityReportModel({
    required this.status,
    required this.confidenceScore,
    required this.detectionMessage,
    required this.severity,
    required this.priority,
    required this.reason,
    required this.description,
    required this.recommendationTitle,
    required this.recommendationText,
    required this.suggestedActions,
    required this.anomalies,
    required this.emailId,
    required this.analysisEngine,
  });

  factory SecurityReportModel.fromJson(Map<String, dynamic> json) {
    return SecurityReportModel(
      status: json['status'] as String,
      confidenceScore: json['confidenceScore'] as int,
      detectionMessage: json['detectionMessage'] as String,
      severity: json['severity'] as String,
      priority: json['priority'] as String,
      reason: json['reason'] as String,
      description: json['description'] as String,
      recommendationTitle: json['recommendationTitle'] as String,
      recommendationText: json['recommendationText'] as String,
      suggestedActions: (json['suggestedActions'] as List<dynamic>).map((e) => e as String).toList(),
      anomalies: (json['anomalies'] as List<dynamic>).map((e) => SecurityReportAnomaly.fromJson(e as Map<String, dynamic>)).toList(),
      emailId: json['emailId'] as String,
      analysisEngine: json['analysisEngine'] as String,
    );
  }
}
