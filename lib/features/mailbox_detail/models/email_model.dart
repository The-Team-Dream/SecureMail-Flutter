import 'package:flutter/material.dart';
import 'package:securemail/core/utils/date_formatter.dart';
import 'attachment_model.dart';
import 'mailbox_message.dart';

class EmailModel {
  final int id;
  final int mailBoxId;
  final String subject;
  final String fromAddr;
  final String? fromName;
  final List<String> toAddr;
  final String? bodyText;
  final String? bodyHtml;
  final bool isRead;
  final bool isFlagged;
  final bool isSpam;
  final bool isPhishing;
  final double spamScore;
  final double phishingScore;
  final String? malwareVerdict;
  final Map<String, dynamic>? aiReport;
  final Map<String, dynamic>? securityReport;
  final String receivedAt;
  final List<AttachmentModel> attachments;

  EmailModel({
    required this.id,
    required this.mailBoxId,
    required this.subject,
    required this.fromAddr,
    this.fromName,
    required this.toAddr,
    this.bodyText,
    this.bodyHtml,
    required this.isRead,
    required this.isFlagged,
    required this.isSpam,
    required this.isPhishing,
    required this.spamScore,
    required this.phishingScore,
    this.malwareVerdict,
    this.aiReport,
    this.securityReport,
    required this.receivedAt,
    required this.attachments,
  });

  EmailModel copyWith({
    int? id,
    int? mailBoxId,
    String? subject,
    String? fromAddr,
    String? fromName,
    List<String>? toAddr,
    String? bodyText,
    String? bodyHtml,
    bool? isRead,
    bool? isFlagged,
    bool? isSpam,
    bool? isPhishing,
    double? spamScore,
    double? phishingScore,
    String? malwareVerdict,
    Map<String, dynamic>? aiReport,
    Map<String, dynamic>? securityReport,
    String? receivedAt,
    List<AttachmentModel>? attachments,
  }) {
    return EmailModel(
      id:              id ?? this.id,
      mailBoxId:       mailBoxId ?? this.mailBoxId,
      subject:         subject ?? this.subject,
      fromAddr:        fromAddr ?? this.fromAddr,
      fromName:        fromName ?? this.fromName,
      toAddr:          toAddr ?? this.toAddr,
      bodyText:        bodyText ?? this.bodyText,
      bodyHtml:        bodyHtml ?? this.bodyHtml,
      isRead:          isRead ?? this.isRead,
      isFlagged:       isFlagged ?? this.isFlagged,
      isSpam:          isSpam ?? this.isSpam,
      isPhishing:      isPhishing ?? this.isPhishing,
      spamScore:       spamScore ?? this.spamScore,
      phishingScore:   phishingScore ?? this.phishingScore,
      malwareVerdict:  malwareVerdict ?? this.malwareVerdict,
      aiReport:        aiReport ?? this.aiReport,
      securityReport:  securityReport ?? this.securityReport,
      receivedAt:      receivedAt ?? this.receivedAt,
      attachments:     attachments ?? this.attachments,
    );
  }

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(
      id:              json['id'] as int,
      mailBoxId:       json['mailBoxId'] as int,
      subject:         json['subject'] as String? ?? '(No Subject)',
      fromAddr:        json['fromAddr'] as String? ?? '',
      fromName:        json['fromName'] as String?,
      toAddr:          (json['toAddr'] as List?)?.map((e) => e as String).toList() ?? [],
      bodyText:        json['bodyText'] as String?,
      bodyHtml:        json['bodyHtml'] as String?,
      isRead:          json['isRead'] as bool? ?? false,
      isFlagged:       json['isFlagged'] as bool? ?? false,
      isSpam:          json['isSpam'] as bool? ?? false,
      isPhishing:      json['isPhishing'] as bool? ?? false,
      spamScore:       (json['spamScore'] ?? 0).toDouble(),
      phishingScore:   (json['phishingScore'] ?? 0).toDouble(),
      malwareVerdict:  json['malwareVerdict'] as String?,
      aiReport:        json['aiReport'] as Map<String, dynamic>?,
      securityReport:  json['securityReport'] as Map<String, dynamic>?,
      receivedAt:      json['receivedAt'] as String? ?? '',
      attachments:     (json['attachments'] as List?)
              ?.map((a) => AttachmentModel.fromJson(a))
              .toList() ?? [],
    );
  }

  String get senderDisplay => fromName ?? fromAddr;

  MailboxMessage toMailboxMessage() {
    final initials = senderDisplay.length >= 2 
        ? senderDisplay.substring(0, 2).toUpperCase() 
        : senderDisplay.toUpperCase();

    String badgeLabel = 'VERIFIED';
    Color badgeColor = const Color(0xFF8CEB2F);

    if (isPhishing) {
      badgeLabel = 'PHISHING';
      badgeColor = const Color(0xFFFF5252);
    } else if (isSpam) {
      badgeLabel = 'SPAM';
      badgeColor = const Color(0xFFFFB74D);
    } else if (malwareVerdict != null && malwareVerdict != 'clean') {
      badgeLabel = 'MALWARE';
      badgeColor = const Color(0xFFFF5252);
    }

    return MailboxMessage(
      id:          id.toString(),
      mailboxId:   mailBoxId,
      initials:    initials,
      sender:      senderDisplay,
      subject:     subject,
      preview:     bodyText ?? '',
      timeLabel:   _formatTime(receivedAt),
      badgeLabel:  badgeLabel,
      badgeColor:  badgeColor,
      isActive:    !isRead,
      hasAttachments: attachments.isNotEmpty,
      attachmentNames: attachments.map((a) => a.filename).toList(),
    );
  }

  String _formatTime(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    return DateFormatter.emailTime(date);
  }
}
