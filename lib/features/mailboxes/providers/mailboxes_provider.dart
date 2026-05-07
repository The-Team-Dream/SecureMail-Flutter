import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/network/api_client.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import 'package:securemail/features/mailboxes/models/mailbox_model.dart';
import 'package:dio/dio.dart';
import 'package:securemail/core/enums/encryption_mode.dart';
import 'package:url_launcher/url_launcher.dart';



// ── State ──────────────────────────────────────────────────

class MailboxesState {
  const MailboxesState({
    this.mailboxes = const [],
    this.isLoading = false,
    this.error,
  });

  final List<MailboxModel> mailboxes;
  final bool isLoading;
  final String? error;

  MailboxesState copyWith({
    List<MailboxModel>? mailboxes,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MailboxesState(
      mailboxes: mailboxes ?? this.mailboxes,
      isLoading: isLoading ?? this.isLoading,
      error:     clearError ? null : error ?? this.error,
    );
  }

  int get activeCount => mailboxes.where((m) => m.isActive).length;
}

// ── Notifier ───────────────────────────────────────────────

class MailboxesNotifier extends StateNotifier<MailboxesState> {
  MailboxesNotifier() : super(const MailboxesState()) {
    fetchMailboxes();
  }

  // ── Fetch Mailboxes ───────────────────────────────────────
  /// GET /mailboxes
  Future<void> fetchMailboxes() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.get(ApiConstants.mailboxes);
      final List<dynamic> data = response.data['data'];
      state = state.copyWith(
        isLoading: false,
        mailboxes: data.map((m) => MailboxModel.fromJson(m)).toList(),
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e, 'Failed to load mailboxes.'),
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load mailboxes.');
    }
  }

  // ── Add Mailbox ───────────────────────────────────────────
  /// POST /mailboxes/imap
  Future<bool> addMailbox(AddMailboxFormData data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Map form data to backend DTO
      final payload = {
        'host':        data.imapHost,
        'port':        data.imapPort,
        'email':       data.email,
        'password':    data.imapPassword,
        'secure':      true, // Defaulting to secure for simplicity
        'displayName': data.displayName ?? data.email,
        'smtpHost':    data.smtpHost,
        'smtpPort':    data.smtpPort,
      };

      await ApiClient.post(ApiConstants.connectImap, data: payload);
      await fetchMailboxes();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e, 'Failed to connect mailbox.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred.');
      return false;
    }
  }

  // ── OAuth Connections ─────────────────────────────────────
  
  /// GET /mailboxes/[gmail|outlook]/auth-url
  Future<String?> getOAuthUrl(MailboxProvider provider, String redirectUri) async {
    try {
      final endpoint = provider == MailboxProvider.gmail 
          ? ApiConstants.gmailAuthUrl 
          : ApiConstants.outlookAuthUrl;
          
      final response = await ApiClient.get(
        endpoint, 
        queryParameters: {'redirectUri': redirectUri},
      );
      return response.data['data']['url'] as String;
    } catch (_) {
      return null;
    }
  }

  /// POST /mailboxes/[gmail|outlook]
  Future<bool> connectOAuth({
    required MailboxProvider provider,
    required String code,
    required String redirectUri,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final endpoint = provider == MailboxProvider.gmail 
          ? ApiConstants.connectGmail 
          : ApiConstants.connectOutlook;
          
      await ApiClient.post(endpoint, data: {
        'code': code,
        'redirectUri': redirectUri,
      });
      
      await fetchMailboxes();
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e, 'Failed to connect account.'),
      );
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred.');
      return false;
    }
  }


  // ── Remove Mailbox ────────────────────────────────────────
  /// DELETE /mailboxes/:id
  Future<bool> removeMailbox(int mailboxId) async {
    try {
      await ApiClient.delete(ApiConstants.mailboxById(mailboxId));
      await fetchMailboxes();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Manual Sync ───────────────────────────────────────────
  /// POST /mailboxes/:id/sync
  Future<bool> retrySync(int mailboxId) async {
    try {
      await ApiClient.post(ApiConstants.syncMailbox(mailboxId));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Helper ───────────────────────────────────────────────
  String _extractError(DioException e, String fallback) {
    try {
      final data = e.response?.data;
      if (data is Map) return data['message'] as String? ?? fallback;
    } catch (_) {}
    return fallback;
  }
}

// ── Form Data ──────────────────────────────────────────────


class AddMailboxFormData {
  String? displayName;
  MailboxProvider? provider;
  String? email;
  String? imapHost;
  int? imapPort;
  String? imapPassword;
  EncryptionMode? imapEncryption;
  String? smtpHost;
  int? smtpPort;
  String? smtpPassword;
  EncryptionMode? smtpEncryption;
  String? syncFrequency;
  int? fetchLimit;
  bool securityScanEnabled;

  AddMailboxFormData({
    this.displayName,
    this.provider,
    this.email,
    this.imapHost,
    this.imapPort,
    this.imapPassword,
    this.imapEncryption,
    this.smtpHost,
    this.smtpPort,
    this.smtpPassword,
    this.smtpEncryption,
    this.syncFrequency,
    this.fetchLimit = 50,
    this.securityScanEnabled = true,
  });

  AddMailboxFormData copyWith({
    String? displayName,
    MailboxProvider? provider,
    String? email,
    String? imapHost,
    int? imapPort,
    String? imapPassword,
    EncryptionMode? imapEncryption,
    String? smtpHost,
    int? smtpPort,
    String? smtpPassword,
    EncryptionMode? smtpEncryption,
    String? syncFrequency,
    int? fetchLimit,
    bool? securityScanEnabled,
  }) {
    return AddMailboxFormData(
      displayName:         displayName         ?? this.displayName,
      provider:            provider            ?? this.provider,
      email:               email               ?? this.email,
      imapHost:            imapHost            ?? this.imapHost,
      imapPort:            imapPort            ?? this.imapPort,
      imapPassword:        imapPassword        ?? this.imapPassword,
      imapEncryption:      imapEncryption      ?? this.imapEncryption,
      smtpHost:            smtpHost            ?? this.smtpHost,
      smtpPort:            smtpPort            ?? this.smtpPort,
      smtpPassword:        smtpPassword        ?? this.smtpPassword,
      smtpEncryption:      smtpEncryption      ?? this.smtpEncryption,
      syncFrequency:       syncFrequency       ?? this.syncFrequency,
      fetchLimit:          fetchLimit          ?? this.fetchLimit,
      securityScanEnabled: securityScanEnabled ?? this.securityScanEnabled,
    );
  }
}

// ── Providers ─────────────────────────────────────────────

final mailboxesProvider = StateNotifierProvider<MailboxesNotifier, MailboxesState>(
  (ref) => MailboxesNotifier(),
);

final addMailboxFormProvider = StateNotifierProvider<AddMailboxFormNotifier, AddMailboxFormData>(
  (ref) => AddMailboxFormNotifier(),
);

class AddMailboxFormNotifier extends StateNotifier<AddMailboxFormData> {
  AddMailboxFormNotifier() : super(AddMailboxFormData());

  void updateStep1({required String displayName, required MailboxProvider provider}) {
    state = state.copyWith(displayName: displayName, provider: provider);
  }

  void updateStep2({
    required String email, 
    required String imapHost, 
    required int imapPort, 
    required String imapPassword,
    required EncryptionMode imapEncryption,
  }) {
    state = state.copyWith(
      email: email, 
      imapHost: imapHost, 
      imapPort: imapPort, 
      imapPassword: imapPassword,
      imapEncryption: imapEncryption,
    );
  }

  void updateStep3({
    required String smtpHost, 
    required int smtpPort,
    required EncryptionMode smtpEncryption,
    String? smtpPassword,
  }) {
    state = state.copyWith(
      smtpHost: smtpHost, 
      smtpPort: smtpPort,
      smtpEncryption: smtpEncryption,
      smtpPassword: smtpPassword,
    );
  }

  void updateStep4({
    required String syncFrequency,
    required int fetchLimit,
    required bool securityScanEnabled,
  }) {
    state = state.copyWith(
      syncFrequency: syncFrequency,
      fetchLimit: fetchLimit,
      securityScanEnabled: securityScanEnabled,
    );
  }

  void reset() => state = AddMailboxFormData();
}
