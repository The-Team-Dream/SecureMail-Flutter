import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/network/api_client.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import 'package:securemail/features/mailbox_detail/models/email_model.dart';
import 'package:securemail/features/mailbox_detail/models/paginated_emails_model.dart';
import 'package:dio/dio.dart';
import 'dart:io';

// ── State ──────────────────────────────────────────────────

import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';

class MessagesState {
  const MessagesState({
    this.isLoading = false,
    this.error,
    this.inbox = const [],
    this.sent = const [],
    this.spam = const [],
    this.malware = const [],
    this.phishing = const [],
    this.trash = const [],
    this.searchResult = const [],
    this.selectedEmail,
  });

  final bool isLoading;
  final String? error;
  final List<EmailModel> inbox;
  final List<EmailModel> sent;
  final List<EmailModel> spam;
  final List<EmailModel> malware;
  final List<EmailModel> phishing;
  final List<EmailModel> trash;
  final List<EmailModel> searchResult;
  final EmailModel? selectedEmail;

  // ── UI Compatibility Getters ──────────────────────────────

  List<MailboxMessage> get inboxMessages => inbox.map((e) => e.toMailboxMessage()).toList();
  List<MailboxMessage> get sentMessages => sent.map((e) => e.toMailboxMessage()).toList();
  List<MailboxMessage> get spamMessages => spam.map((e) => e.toMailboxMessage()).toList();
  List<MailboxMessage> get malwareMessages => malware.map((e) => e.toMailboxMessage()).toList();
  List<MailboxMessage> get phishingMessages => phishing.map((e) => e.toMailboxMessage()).toList();
  List<MailboxMessage> get trashMessages => trash.map((e) => e.toMailboxMessage()).toList();

  MessagesState copyWith({
    bool? isLoading,
    String? error,
    List<EmailModel>? inbox,
    List<EmailModel>? sent,
    List<EmailModel>? spam,
    List<EmailModel>? malware,
    List<EmailModel>? phishing,
    List<EmailModel>? trash,
    List<EmailModel>? searchResult,
    EmailModel? selectedEmail,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return MessagesState(
      isLoading:    isLoading    ?? this.isLoading,
      error:        clearError   ? null : error ?? this.error,
      inbox:        inbox        ?? this.inbox,
      sent:         sent         ?? this.sent,
      spam:         spam         ?? this.spam,
      malware:      malware      ?? this.malware,
      phishing:     phishing     ?? this.phishing,
      trash:        trash        ?? this.trash,
      searchResult: searchResult ?? this.searchResult,
      selectedEmail: clearSelected ? null : selectedEmail ?? this.selectedEmail,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────

class MessagesNotifier extends StateNotifier<MessagesState> {
  MessagesNotifier() : super(const MessagesState());

  // ── Fetch Folders ─────────────────────────────────────────

  Future<void> fetchInbox(int mailboxId, {int page = 1}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.get(ApiConstants.inbox(mailboxId), queryParameters: {'page': page});
      final paginated = PaginatedEmailsModel.fromJson(response.data['data']);
      state = state.copyWith(isLoading: false, inbox: paginated.data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchSent(int mailboxId) async {
    try {
      final response = await ApiClient.get(ApiConstants.sent(mailboxId));
      final paginated = PaginatedEmailsModel.fromJson(response.data['data']);
      state = state.copyWith(sent: paginated.data);
    } catch (_) {}
  }

  Future<void> fetchSpam(int mailboxId) async {
    try {
      final response = await ApiClient.get(ApiConstants.spam(mailboxId));
      final paginated = PaginatedEmailsModel.fromJson(response.data['data']);
      state = state.copyWith(spam: paginated.data);
    } catch (_) {}
  }

  Future<void> fetchPhishing(int mailboxId) async {
    try {
      final response = await ApiClient.get(ApiConstants.phishing(mailboxId));
      final paginated = PaginatedEmailsModel.fromJson(response.data['data']);
      state = state.copyWith(phishing: paginated.data);
    } catch (_) {}
  }

  Future<void> fetchMalware(int mailboxId) async {
    try {
      final response = await ApiClient.get(ApiConstants.malware(mailboxId));
      final paginated = PaginatedEmailsModel.fromJson(response.data['data']);
      state = state.copyWith(malware: paginated.data);
    } catch (_) {}
  }

  Future<void> search(int mailboxId, String query) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.get(
        ApiConstants.searchEmails(mailboxId), 
        queryParameters: {'q': query},
      );
      final paginated = PaginatedEmailsModel.fromJson(response.data['data']);
      state = state.copyWith(isLoading: false, searchResult: paginated.data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchEmailDetail(int mailboxId, int emailId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSelected: true);
    try {
      final response = await ApiClient.get(ApiConstants.emailById(mailboxId, emailId));
      final email = EmailModel.fromJson(response.data['data']);
      state = state.copyWith(isLoading: false, selectedEmail: email);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearSelected() {
    state = state.copyWith(clearSelected: true);
  }

  // ── Actions ───────────────────────────────────────────────

  Future<bool> markRead(int mailboxId, int emailId, bool read) async {
    try {
      await ApiClient.patch(ApiConstants.markEmailRead(mailboxId, emailId), data: {'read': read});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteMessage(int mailboxId, int emailId) async {
    try {
      await ApiClient.delete(ApiConstants.deleteEmail(mailboxId, emailId));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reclassifyMessage(int mailboxId, int emailId, String targetFolder) async {
    try {
      await ApiClient.patch(
        ApiConstants.reclassifyEmail(mailboxId, emailId),
        data: {'folder': targetFolder.toLowerCase()},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Send ──────────────────────────────────────────────────

  Future<bool> sendEmail({
    required int mailboxId,
    required String to,
    required String subject,
    String? bodyText,
    String? bodyHtml,
    List<File>? attachments,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final Map<String, dynamic> map = {
        'to':       to,
        'subject':  subject,
        'bodyText': bodyText,
        'bodyHtml': bodyHtml,
      };

      if (attachments != null && attachments.isNotEmpty) {
        map['attachments'] = await Future.wait(attachments.map((f) => MultipartFile.fromFile(f.path)));
      }

      final formData = FormData.fromMap(map);
      await ApiClient.post(ApiConstants.sendEmail(mailboxId), data: formData);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

// ── Provider ───────────────────────────────────────────────

final messagesProvider = StateNotifierProvider<MessagesNotifier, MessagesState>((ref) {
  return MessagesNotifier();
});
