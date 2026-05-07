class AnalyticsOverviewModel {
  final int totalMailboxesConnected;
  final int totalEmails;
  final int totalPhishingDetected;
  final int totalSpamDetected;
  final int totalStorageUsed;

  AnalyticsOverviewModel({
    required this.totalMailboxesConnected,
    required this.totalEmails,
    required this.totalPhishingDetected,
    required this.totalSpamDetected,
    required this.totalStorageUsed,
  });

  factory AnalyticsOverviewModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverviewModel(
      totalMailboxesConnected: json['totalMailboxesConnected'] as int? ?? 0,
      totalEmails:             json['totalEmails'] as int? ?? 0,
      totalPhishingDetected:   json['totalPhishingDetected'] as int? ?? 0,
      totalSpamDetected:       json['totalSpamDetected'] as int? ?? 0,
      totalStorageUsed:        json['totalStorageUsed'] as int? ?? 0,
    );
  }
}

class ActivityDataPoint {
  final String date;
  final int received;
  final int sent;
  final int spam;
  final int phishing;

  ActivityDataPoint({
    required this.date,
    required this.received,
    required this.sent,
    required this.spam,
    required this.phishing,
  });

  factory ActivityDataPoint.fromJson(Map<String, dynamic> json) {
    return ActivityDataPoint(
      date:     json['date'] as String? ?? '',
      received: json['received'] as int? ?? 0,
      sent:     json['sent'] as int? ?? 0,
      spam:     json['spam'] as int? ?? 0,
      phishing: json['phishing'] as int? ?? 0,
    );
  }
}
