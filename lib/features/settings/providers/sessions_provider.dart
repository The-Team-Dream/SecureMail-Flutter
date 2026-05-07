import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/core/network/api_client.dart';
import 'package:securemail/core/constants/ApiConstants.dart';
import 'package:securemail/features/settings/models/session_model.dart';
import 'package:dio/dio.dart';

// ── State ──────────────────────────────────────────────────

class SessionsState {
  const SessionsState({
    this.isLoading = false,
    this.error,
    this.sessions = const [],
  });

  final bool isLoading;
  final String? error;
  final List<SessionModel> sessions;

  SessionsState copyWith({
    bool? isLoading,
    String? error,
    List<SessionModel>? sessions,
    bool clearError = false,
  }) {
    return SessionsState(
      isLoading: isLoading ?? this.isLoading,
      error:     clearError ? null : error ?? this.error,
      sessions:  sessions  ?? this.sessions,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────

class SessionsNotifier extends StateNotifier<SessionsState> {
  SessionsNotifier() : super(const SessionsState()) {
    fetchSessions();
  }

  // ── Fetch Sessions ────────────────────────────────────────
  /// GET /sessions
  Future<void> fetchSessions() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.get(ApiConstants.sessions);
      final List<dynamic> data = response.data['data'];
      state = state.copyWith(
        isLoading: false,
        sessions: data.map((s) => SessionModel.fromJson(s)).toList(),
      );
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _extractError(e, 'Failed to load sessions.'),
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Failed to load sessions.');
    }
  }

  // ── Revoke Specific Session ───────────────────────────────
  /// DELETE /sessions/:id
  Future<bool> revokeSession(int id) async {
    try {
      await ApiClient.delete(ApiConstants.sessionById(id));
      // Refresh list
      await fetchSessions();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── Revoke All Other Sessions ────────────────────────────
  /// DELETE /sessions
  Future<bool> revokeAllSessions() async {
    try {
      await ApiClient.delete(ApiConstants.sessions);
      // Refresh list
      await fetchSessions();
      return true;
    } catch (e) {
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

// ── Provider ───────────────────────────────────────────────

final sessionsProvider = StateNotifierProvider<SessionsNotifier, SessionsState>(
  (ref) => SessionsNotifier(),
);
