import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:securemail/features/mailbox_detail/models/mailbox_message.dart';

class MessagesState {
  final List<MailboxMessage> inbox;
  final List<MailboxMessage> sent;
  final List<MailboxMessage> spam;
  final List<MailboxMessage> malware;
  final List<MailboxMessage> phishing;

  MessagesState({
    required this.inbox,
    required this.sent,
    required this.spam,
    required this.malware,
    required this.phishing,
  });

  MessagesState copyWith({
    List<MailboxMessage>? inbox,
    List<MailboxMessage>? sent,
    List<MailboxMessage>? spam,
    List<MailboxMessage>? malware,
    List<MailboxMessage>? phishing,
  }) {
    return MessagesState(
      inbox: inbox ?? this.inbox,
      sent: sent ?? this.sent,
      spam: spam ?? this.spam,
      malware: malware ?? this.malware,
      phishing: phishing ?? this.phishing,
    );
  }
}

class MessagesNotifier extends StateNotifier<MessagesState> {
  MessagesNotifier()
      : super(MessagesState(
          inbox: List.from(MailboxMockMessages.inbox),
          sent: List.from(MailboxMockMessages.sent),
          spam: List.from(MailboxMockMessages.spam),
          malware: List.from(MailboxMockMessages.malware),
          phishing: List.from(MailboxMockMessages.phishing),
        ));

  Future<void> reclassifyMessage(
      MailboxMessage message, String targetFolder) async {
    // 1. Determine current folder and remove message
    List<MailboxMessage> newInbox = List.from(state.inbox);
    List<MailboxMessage> newSent = List.from(state.sent);
    List<MailboxMessage> newSpam = List.from(state.spam);
    List<MailboxMessage> newMalware = List.from(state.malware);
    List<MailboxMessage> newPhishing = List.from(state.phishing);

    bool removed = false;
    
    if (newInbox.any((m) => m.id == message.id)) {
      newInbox.removeWhere((m) => m.id == message.id);
      removed = true;
    } else if (newSent.any((m) => m.id == message.id)) {
      newSent.removeWhere((m) => m.id == message.id);
      removed = true;
    } else if (newSpam.any((m) => m.id == message.id)) {
      newSpam.removeWhere((m) => m.id == message.id);
      removed = true;
    } else if (newMalware.any((m) => m.id == message.id)) {
      newMalware.removeWhere((m) => m.id == message.id);
      removed = true;
    } else if (newPhishing.any((m) => m.id == message.id)) {
      newPhishing.removeWhere((m) => m.id == message.id);
      removed = true;
    }

    if (!removed) return;

    // 2. Add to target folder
    final target = targetFolder.toLowerCase();
    if (target == 'inbox' || target == 'clean / safe') {
      newInbox.insert(0, message);
    } else if (target == 'spam') {
      newSpam.insert(0, message);
    } else if (target == 'malware') {
      newMalware.insert(0, message);
    } else if (target == 'phishing') {
      newPhishing.insert(0, message);
    }

    state = state.copyWith(
      inbox: newInbox,
      sent: newSent,
      spam: newSpam,
      malware: newMalware,
      phishing: newPhishing,
    );

    // 3. Notify Backend (Simulated API call)
    // In a real app, this would be: await _api.moveMessage(message.id, targetFolder);
    print('BACKEND NOTIFICATION: Message ${message.id} moved to $targetFolder');
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> deleteMessage(MailboxMessage message) async {
    List<MailboxMessage> newInbox = List.from(state.inbox);
    List<MailboxMessage> newSent = List.from(state.sent);
    List<MailboxMessage> newSpam = List.from(state.spam);
    List<MailboxMessage> newMalware = List.from(state.malware);
    List<MailboxMessage> newPhishing = List.from(state.phishing);

    newInbox.removeWhere((m) => m.id == message.id);
    newSent.removeWhere((m) => m.id == message.id);
    newSpam.removeWhere((m) => m.id == message.id);
    newMalware.removeWhere((m) => m.id == message.id);
    newPhishing.removeWhere((m) => m.id == message.id);

    state = state.copyWith(
      inbox: newInbox,
      sent: newSent,
      spam: newSpam,
      malware: newMalware,
      phishing: newPhishing,
    );

    print('BACKEND NOTIFICATION: Message ${message.id} deleted');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void addSentMessage(MailboxMessage message) {
    state = state.copyWith(sent: [message, ...state.sent]);
  }
}

final messagesProvider =
    StateNotifierProvider<MessagesNotifier, MessagesState>((ref) {
  return MessagesNotifier();
});
