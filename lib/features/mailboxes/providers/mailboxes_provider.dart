import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/enums/encryption_mode.dart';
import 'package:securemail/features/mailboxes/models/mailbox_model.dart';

// ─── Mailboxes State ──────────────────────────────────────

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
      error: clearError ? null : error ?? this.error,
    );
  }

  int get activeCount =>
      mailboxes.where((m) => m.syncStatus != MailboxSyncStatus.reauth).length;
}

// ─── Mailboxes Notifier ────────────────────────────────────

class MailboxesNotifier extends StateNotifier<MailboxesState> {
  MailboxesNotifier() : super(const MailboxesState()) {
    _loadInitialMailboxes();
  }

  void _loadInitialMailboxes() {
    // TODO: Replace with real API call — load mailboxes from backend.
  }

  /// Creates a new mailbox with optimistic UI update.
  ///
  /// 1. Adds a temporary mailbox locally (syncing state).
  /// 2. Sends data to the backend.
  /// 3. On success, replaces the temp ID with the real one.
  /// 4. On failure, marks the mailbox as error.
  Future<bool> addMailbox(AddMailboxFormData data) async {
    final tempId = 'mailbox_${DateTime.now().millisecondsSinceEpoch}';

    final newMailbox = MailboxModel(
      id: tempId,
      displayName: data.displayName ?? data.email ?? 'New Mailbox',
      email: data.email ?? '',
      provider: data.provider ?? MailboxProvider.imap,
      syncStatus: MailboxSyncStatus.syncing,
      syncProgress: 0.0,
      imapHost: data.imapHost,
      imapPort: data.imapPort,
      imapEncryption: data.imapEncryption,
      smtpHost: data.smtpHost,
      smtpPort: data.smtpPort,
      smtpEncryption: data.smtpEncryption,
      syncFrequency: data.syncFrequency,
      fetchLimit: data.fetchLimit,
      securityScanEnabled: data.securityScanEnabled,
    );

    // Optimistic update — show immediately in UI.
    state = state.copyWith(mailboxes: [...state.mailboxes, newMailbox]);

    try {
      // TODO: Replace with real API call.
      // Example:
      //   final res = await _dio.post('/mailboxes', data: data.toJson());
      //   final realId = res.data['id'] as String;
      //   _finalizeMailbox(tempId, realId);

      // ── Simulated progress (remove when API is ready) ──
      await Future.delayed(const Duration(milliseconds: 600));
      _updateSyncProgress(tempId, 0.30);

      await Future.delayed(const Duration(milliseconds: 800));
      _updateSyncProgress(tempId, 0.60);

      await Future.delayed(const Duration(milliseconds: 700));
      _updateSyncProgress(tempId, 0.90);

      final realId = 'mailbox_${DateTime.now().millisecondsSinceEpoch}';
      _finalizeMailbox(tempId, realId);
      // ── End simulated ──

      return true;
    } catch (e) {
      _markMailboxError(tempId);
      state = state.copyWith(error: 'Failed to connect mailbox: $e');
      return false;
    }
  }

  void _updateSyncProgress(String mailboxId, double progress) {
    state = state.copyWith(
      mailboxes: state.mailboxes.map((m) {
        if (m.id == mailboxId) return m.copyWith(syncProgress: progress);
        return m;
      }).toList(),
    );
  }

  void _finalizeMailbox(String tempId, String realId) {
    state = state.copyWith(
      mailboxes: state.mailboxes.map((m) {
        if (m.id == tempId) {
          return m.copyWith(
            id: realId,
            syncStatus: MailboxSyncStatus.synced,
            syncProgress: 1.0,
            lastSyncAt: DateTime.now(),
          );
        }
        return m;
      }).toList(),
    );
  }

  void _markMailboxError(String mailboxId) {
    state = state.copyWith(
      mailboxes: state.mailboxes.map((m) {
        if (m.id == mailboxId) {
          return m.copyWith(syncStatus: MailboxSyncStatus.error);
        }
        return m;
      }).toList(),
    );
  }

  Future<void> removeMailbox(String mailboxId) async {
    // TODO: API call to remove mailbox from backend.
    state = state.copyWith(
      mailboxes: state.mailboxes.where((m) => m.id != mailboxId).toList(),
    );
  }

  Future<void> retrySync(String mailboxId) async {
    _updateSyncProgress(mailboxId, 0.0);
    state = state.copyWith(
      mailboxes: state.mailboxes.map((m) {
        if (m.id == mailboxId) {
          return m.copyWith(
              syncStatus: MailboxSyncStatus.syncing, syncProgress: 0.0);
        }
        return m;
      }).toList(),
    );

    // TODO: Replace with real API sync call.
    await Future.delayed(const Duration(seconds: 2));
    _finalizeMailbox(mailboxId, mailboxId);
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ─── Add Mailbox Form Notifier ────────────────────────────

class AddMailboxFormNotifier extends StateNotifier<AddMailboxFormData> {
  AddMailboxFormNotifier() : super(AddMailboxFormData());

  void updateStep1({
    required String displayName,
    required MailboxProvider provider,
  }) {
    state = state.copyWith(displayName: displayName, provider: provider);
  }

  void updateStep2({
    required String email,
    required String imapHost,
    required int imapPort,
    required EncryptionMode imapEncryption,
    required String imapPassword,
  }) {
    state = state.copyWith(
      email: email,
      imapHost: imapHost,
      imapPort: imapPort,
      imapEncryption: imapEncryption,
      imapPassword: imapPassword,
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

  /// Clears all form data so the next "Add Mailbox" starts fresh.
  void reset() => state = AddMailboxFormData();
}

// ─── Providers ────────────────────────────────────────────

/// Manages the list of mailboxes and their sync state.
final mailboxesProvider =
    StateNotifierProvider<MailboxesNotifier, MailboxesState>(
  (ref) => MailboxesNotifier(),
);

/// Holds the multi-step form data across all 5 screens.
///
/// ⚠️  NOT autoDispose — the data must survive navigating between steps.
/// Without listeners between steps, autoDispose would wipe the state.
final addMailboxFormProvider =
    StateNotifierProvider<AddMailboxFormNotifier, AddMailboxFormData>(
  (ref) => AddMailboxFormNotifier(),
);
