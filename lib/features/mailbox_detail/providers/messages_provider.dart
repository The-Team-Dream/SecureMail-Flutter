import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/network/api_client.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import 'package:securemail/features/auth/providers/auth_provider.dart';
import 'package:securemail/features/mailbox_detail/models/email_model.dart';
import 'package:securemail/features/mailbox_detail/models/paginated_emails_model.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';
import 'package:securemail/core/network/socket_service.dart';

// ── State ──────────────────────────────────────────────────

class MessagesState {
  const MessagesState({
    this.currentMailboxId,
    this.isLoading = false,
    this.isFetchingMore = false,
    this.error,
    this.inbox = const [],
    this.sent = const [],
    this.spam = const [],
    this.malware = const [],
    this.phishing = const [],
    this.trash = const [],
    this.searchResult = const [],
    this.reports = const [],
    this.securityStats = const {'critical': 0, 'resolved': 0, 'pending': 0},
    this.selectedEmail,
    this.currentPage = 1,
    this.hasMore = true,
  });

  final int? currentMailboxId;
  final bool isLoading;
  final bool isFetchingMore;
  final String? error;
  final List<EmailModel> inbox;
  final List<EmailModel> sent;
  final List<EmailModel> spam;
  final List<EmailModel> malware;
  final List<EmailModel> phishing;
  final List<EmailModel> trash;
  final List<EmailModel> searchResult;
  final List<dynamic> reports;
  final Map<String, int> securityStats;
  final EmailModel? selectedEmail;
  final int currentPage;
  final bool hasMore;

  // ── UI Compatibility Getters ──────────────────────────────

  List<MailboxMessage> get inboxMessages => inbox.map((e) => e.toMailboxMessage()).toList();
  List<MailboxMessage> get sentMessages => sent.map((e) => e.toMailboxMessage()).toList();
  List<MailboxMessage> get spamMessages => spam.map((e) => e.toMailboxMessage()).toList();
  List<MailboxMessage> get malwareMessages => malware.map((e) => e.toMailboxMessage()).toList();
  List<MailboxMessage> get phishingMessages => phishing.map((e) => e.toMailboxMessage()).toList();
  List<MailboxMessage> get trashMessages => trash.map((e) => e.toMailboxMessage()).toList();

  MessagesState copyWith({
    int? currentMailboxId,
    bool? isLoading,
    bool? isFetchingMore,
    String? error,
    List<EmailModel>? inbox,
    List<EmailModel>? sent,
    List<EmailModel>? spam,
    List<EmailModel>? malware,
    List<EmailModel>? phishing,
    List<EmailModel>? trash,
    List<EmailModel>? searchResult,
    List<dynamic>? reports,
    Map<String, int>? securityStats,
    EmailModel? selectedEmail,
    int? currentPage,
    bool? hasMore,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return MessagesState(
      currentMailboxId: currentMailboxId ?? this.currentMailboxId,
      isLoading:      isLoading      ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      error:          clearError     ? null : error ?? this.error,
      inbox:          inbox          ?? this.inbox,
      sent:           sent           ?? this.sent,
      spam:           spam           ?? this.spam,
      malware:        malware        ?? this.malware,
      phishing:       phishing       ?? this.phishing,
      trash:          trash          ?? this.trash,
      searchResult:   searchResult   ?? this.searchResult,
      reports:        reports        ?? this.reports,
      securityStats:  securityStats  ?? this.securityStats,
      selectedEmail:  clearSelected  ? null : selectedEmail ?? this.selectedEmail,
      currentPage:    currentPage    ?? this.currentPage,
      hasMore:        hasMore        ?? this.hasMore,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────

class MessagesNotifier extends StateNotifier<MessagesState> {
  MessagesNotifier() : super(const MessagesState()) {
    _listenToSocket();
  }

  void _listenToSocket() {
    // We removed the aggressive refresh on NEW_EMAIL_RECEIVED to prevent flickering.
    // Sync completion is now handled in the Screen UI layer.
  }

  void _checkMailboxChange(int mailboxId) {
    if (state.currentMailboxId != null && state.currentMailboxId != mailboxId) {
      state = MessagesState(currentMailboxId: mailboxId);
    } else if (state.currentMailboxId == null) {
      state = state.copyWith(currentMailboxId: mailboxId);
    }
  }

  // ── Fetch Inbox (Supports Pagination) ─────────────────────

  Future<void> fetchInbox(int mailboxId, {bool refresh = false, bool silent = false}) async {
    _checkMailboxChange(mailboxId);
    if (state.inbox.isEmpty) refresh = true; // Force refresh if we just cleared state
    if (refresh) {
      if (!silent) {
        state = state.copyWith(isLoading: true, clearError: true);
      }
      state = state.copyWith(currentPage: 1, hasMore: true, clearError: true);
      
      // Trigger background sync when manually refreshing (not silent)
      if (!silent) {
        try {
          ApiClient.post(ApiConstants.syncMailbox(mailboxId));
        } catch (_) {}
      }
    } else if (state.isLoading || !state.hasMore || state.isFetchingMore) {
      return;
    }

    if (!refresh && state.inbox.isNotEmpty) {
      state = state.copyWith(isFetchingMore: true);
    }

    try {
      final response = await ApiClient.get(
        ApiConstants.inbox(mailboxId), 
        queryParameters: {
          'page': state.currentPage,
          'limit': 20,
        },
      );
      
      final paginated = PaginatedEmailsModel.fromJson(response.data['data']);
      
      final List<EmailModel> updatedList = refresh 
          ? paginated.data 
          : [...state.inbox, ...paginated.data];

      state = state.copyWith(
        isLoading:      false,
        isFetchingMore: false,
        inbox:          updatedList,
        currentPage:    state.currentPage + 1,
        hasMore:        paginated.data.length == 20, // يفترض أن 20 هي الـ limit
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isFetchingMore: false, error: e.toString());
    }
  }

  // ── Fetch Other Folders (Simple version for now) ──────────

  Future<void> fetchSent(int mailboxId, {bool refresh = false}) async {
    _checkMailboxChange(mailboxId);
    if (refresh) {
      try { ApiClient.post(ApiConstants.syncMailbox(mailboxId)); } catch (_) {}
    }
    try {
      final response = await ApiClient.get(ApiConstants.sent(mailboxId));
      final paginated = PaginatedEmailsModel.fromJson(response.data['data']);
      state = state.copyWith(sent: paginated.data);
    } catch (_) {}
  }

  Future<void> fetchSpam(int mailboxId, {bool refresh = false}) async {
    _checkMailboxChange(mailboxId);
    if (refresh) {
      try { ApiClient.post(ApiConstants.syncMailbox(mailboxId)); } catch (_) {}
    }
    try {
      final response = await ApiClient.get(ApiConstants.spam(mailboxId));
      final paginated = PaginatedEmailsModel.fromJson(response.data['data']);
      state = state.copyWith(spam: paginated.data);
    } catch (_) {}
  }

  Future<void> fetchPhishing(int mailboxId, {bool refresh = false}) async {
    _checkMailboxChange(mailboxId);
    if (refresh) {
      try { ApiClient.post(ApiConstants.syncMailbox(mailboxId)); } catch (_) {}
    }
    try {
      final response = await ApiClient.get(ApiConstants.phishing(mailboxId));
      final paginated = PaginatedEmailsModel.fromJson(response.data['data']);
      state = state.copyWith(phishing: paginated.data);
    } catch (_) {}
  }

  Future<void> fetchMalware(int mailboxId, {bool refresh = false}) async {
    _checkMailboxChange(mailboxId);
    if (refresh) {
      try { ApiClient.post(ApiConstants.syncMailbox(mailboxId)); } catch (_) {}
    }
    try {
      final response = await ApiClient.get(ApiConstants.malware(mailboxId));
      final paginated = PaginatedEmailsModel.fromJson(response.data['data']);
      state = state.copyWith(malware: paginated.data);
    } catch (_) {}
  }

  Future<void> fetchTrash(int mailboxId, {bool refresh = false}) async {
    _checkMailboxChange(mailboxId);
    if (refresh) {
      try { ApiClient.post(ApiConstants.syncMailbox(mailboxId)); } catch (_) {}
    }
    try {
      final response = await ApiClient.get(ApiConstants.trash(mailboxId));
      final paginated = PaginatedEmailsModel.fromJson(response.data['data']);
      state = state.copyWith(trash: paginated.data);
    } catch (_) {}
  }

  Future<void> fetchReports(int mailboxId) async {
    _checkMailboxChange(mailboxId);
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.get(ApiConstants.mailboxReports(mailboxId));
      
      final List<dynamic> reportsData = response.data['data'];
      final Map<String, dynamic> meta = response.data['meta'];
      final Map<String, int> stats = Map<String, int>.from(meta['stats']);

      state = state.copyWith(
        isLoading: false,
        reports: reportsData,
        securityStats: stats,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> search(int mailboxId, String query) async {
    _checkMailboxChange(mailboxId);
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

      // Automatically mark as read if it's not already
      if (!email.isRead) {
        markRead(mailboxId, emailId, true);
        
        // Update local state lists so UI updates immediately
        final updatedInbox = state.inbox.map((e) => e.id == emailId ? e.copyWith(isRead: true) : e).toList();
        final updatedSpam = state.spam.map((e) => e.id == emailId ? e.copyWith(isRead: true) : e).toList();
        final updatedPhishing = state.phishing.map((e) => e.id == emailId ? e.copyWith(isRead: true) : e).toList();
        final updatedTrash = state.trash.map((e) => e.id == emailId ? e.copyWith(isRead: true) : e).toList();

        state = state.copyWith(
          inbox: updatedInbox,
          spam: updatedSpam,
          phishing: updatedPhishing,
          trash: updatedTrash,
        );
      }
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
      
      // Remove from all local lists so UI updates immediately
      state = state.copyWith(
        inbox:    state.inbox.where((e) => e.id != emailId).toList(),
        spam:     state.spam.where((e) => e.id != emailId).toList(),
        phishing: state.phishing.where((e) => e.id != emailId).toList(),
        trash:    state.trash.where((e) => e.id != emailId).toList(),
        malware:  state.malware.where((e) => e.id != emailId).toList(),
        sent:     state.sent.where((e) => e.id != emailId).toList(),
      );
      
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
      
      // Remove from all local lists
      final updatedInbox = state.inbox.where((e) => e.id != emailId).toList();
      final updatedSpam = state.spam.where((e) => e.id != emailId).toList();
      final updatedPhishing = state.phishing.where((e) => e.id != emailId).toList();
      final updatedTrash = state.trash.where((e) => e.id != emailId).toList();
      final updatedMalware = state.malware.where((e) => e.id != emailId).toList();

      state = state.copyWith(
        inbox: updatedInbox,
        spam: updatedSpam,
        phishing: updatedPhishing,
        trash: updatedTrash,
        malware: updatedMalware,
      );

      // Refresh target folder to show the moved email
      switch (targetFolder.toLowerCase()) {
        case 'inbox': fetchInbox(mailboxId, refresh: true); break;
        case 'spam': fetchSpam(mailboxId); break;
        case 'phishing': fetchPhishing(mailboxId); break;
        case 'trash': fetchTrash(mailboxId); break;
        case 'malware': fetchMalware(mailboxId); break;
      }

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
  ref.watch(authProvider.select((s) => s.isAuthenticated));
  return MessagesNotifier();
});
