import 'package:flutter/material.dart';
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
    required this.receivedAt,
    required this.attachments,
  });

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
    );
  }

  String _formatTime(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}';
  }
}
