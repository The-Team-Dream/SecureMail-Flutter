import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/network/socket_service.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/features/mailboxes/models/mailbox_model.dart';
import 'package:securemail/features/mailboxes/providers/mailboxes_provider.dart';
import 'package:securemail/features/mailboxes/screens/add_mailbox/Step1ProviderScreen.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';

class MailboxesScreen extends ConsumerStatefulWidget {
  const MailboxesScreen({super.key});

  @override
  ConsumerState<MailboxesScreen> createState() => _MailboxesScreenState();
}

class _MailboxesScreenState extends ConsumerState<MailboxesScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  StreamSubscription<Map<String, dynamic>>? _syncStartSub;
  StreamSubscription<Map<String, dynamic>>? _syncDoneSub;
  Timer? _timeagoTimer;

  @override
  void initState() {
    super.initState();
    _syncStartSub = socketService.syncStartStream.listen((event) {
      final id = event['mailBoxId'];
      if (id is int && mounted) {
        ref.read(mailboxesProvider.notifier).markSyncStarted(id);
      }
    });
    _syncDoneSub = socketService.syncEventsStream.listen((event) {
      final id = event['mailBoxId'];
      if (id is int && mounted) {
        ref.read(mailboxesProvider.notifier).markSyncCompleted(id);
        ref.read(mailboxesProvider.notifier).fetchMailboxes();
      }
    });
    _timeagoTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }
  @override
  void dispose() {
    _searchCtrl.dispose();
    _syncStartSub?.cancel();
    _syncDoneSub?.cancel();
    _timeagoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mailboxesProvider);
    final mailboxes = state.mailboxes
        .where((m) =>
            _searchQuery.isEmpty ||
            m.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            m.displayName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Search
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.x3,
              ),
              child: Row(
                children: [
                  // Logo
                  SizedBox(
                    width: AppSize.avatarMd,
                    height: AppSize.avatarMd,
                    child: Image.asset(
                      'assets/images/splash.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x3),

                  // Search Bar
                  Expanded(
                    child: Container(
                      height: AppSize.fieldHeight,
                      decoration: BoxDecoration(
                        color: context.fieldBg,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: context.fieldBorder),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: AppSpacing.x4),
                          Icon(Icons.search,
                              size: AppIconSize.md, color: context.text3),
                          const SizedBox(width: AppSpacing.x2),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              textAlignVertical: TextAlignVertical.center,
                              style: AppTextStyles.bodyM.copyWith(
                                color: context.text1,
                                height: 1.0,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'Search mailboxes...',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.x4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.x3,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.x5),
                      decoration: BoxDecoration(
                        color: context.card1,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: context.fieldBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('OVERVIEW',
                                    style: AppTextStyles.labelS.copyWith(
                                      color: context.button1,
                                      letterSpacing: 1.5,
                                    )),
                                const SizedBox(height: AppSpacing.x1 + 2),
                                Text(
                                  '${state.activeCount} Active\nNodes',
                                  style: AppTextStyles.displayM.copyWith(
                                    color: context.text1,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.x2),
                                Text(
                                  'All systems operational',
                                  style: AppTextStyles.bodyS.copyWith(
                                    color: context.text3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const Step1ProviderScreen(),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.button1,
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.x4,
                                vertical: AppSpacing.x2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text('Add Mailbox',
                                style: AppTextStyles.labelS.copyWith(
                                  color: Colors.white,
                                )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x8),

                    // Mailboxes List
                    if (mailboxes.isNotEmpty) ...[
                      Text(
                        'CONNECTED MAILBOXES',
                        style: AppTextStyles.labelS.copyWith(
                          color: context.text3,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.x3),
                      ...mailboxes.map((m) {
                        final syncing = state.isSyncing(m.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.x2),
                          child: _MailboxCard(
                            mailbox: m,
                            isSyncing: syncing,
                            onTap: (syncing && m.lastSyncedAt == null)
                                ? () => ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('First time sync, please wait...'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    )
                                : () => context.go(AppRoutes.inbox(m.id)),
                            onRemove: () => ref
                                .read(mailboxesProvider.notifier)
                                .removeMailbox(m.id),
                            onRetry: () => ref
                                .read(mailboxesProvider.notifier)
                                .retrySync(m.id),
                          ),
                        );
                      }),
                    ] else ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.x16),
                          child: Column(
                            children: [
                              Icon(Icons.mail_outline,
                                  size: AppSize.avatarLg,
                                  color: context.text3.withOpacity(0.5)),
                              const SizedBox(height: AppSpacing.x4),
                              Text('No mailboxes connected',
                                  style: AppTextStyles.bodyM.copyWith(
                                    color: context.text3,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Mailbox Card Widget ──────────────────────────────────

class _MailboxCard extends StatelessWidget {
  const _MailboxCard({
    required this.mailbox,
    required this.onTap,
    required this.onRemove,
    required this.onRetry,
    this.isSyncing = false,
  });

  final MailboxModel mailbox;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onRetry;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x3,
        ),
        decoration: BoxDecoration(
          color: isSyncing
              ? context.button1.withOpacity(0.06)
              : context.card1,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSyncing ? context.button1.withOpacity(0.4) : context.fieldBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppSize.avatarMd,
              height: AppSize.avatarMd,
              decoration: BoxDecoration(
                color: context.button1.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(_providerIcon,
                  color: context.button1, size: AppIconSize.md),
            ),
            const SizedBox(width: AppSpacing.x3),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mailbox.email,
                    style: AppTextStyles.labelM.copyWith(
                      color: context.text1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  _buildStatusWidget(context),
                ],
              ),
            ),

            // Action
            _buildAction(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget(BuildContext context) {
    // Real-time sync indicator takes priority over the model's stored status
    if (isSyncing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              backgroundColor: context.button1.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(context.button1),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Text('Syncing emails…',
              style: AppTextStyles.caption.copyWith(color: context.button1)),
        ],
      );
    }

    switch (mailbox.syncStatus) {
      case MailboxSyncStatus.synced:
        return Row(children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: context.button1,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.x1 + 2),
          Text('Last synced: ${mailbox.lastSyncLabel}',
              style: AppTextStyles.caption.copyWith(color: context.text3)),
        ]);

      case MailboxSyncStatus.syncing:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: LinearProgressIndicator(
                value: mailbox.syncProgress,
                backgroundColor: context.button1.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(context.button1),
                minHeight: 3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'SYNCING (${(mailbox.syncProgress * 100).toInt()}%)',
              style: AppTextStyles.caption.copyWith(
                fontSize: 9,
                color: context.button1,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );

      case MailboxSyncStatus.reauth:
        return Row(children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.x1 + 2),
          const Text('Re-authentication required',
              style: AppTextStyles.caption),
        ]);

      case MailboxSyncStatus.error:
        return Row(children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.x1 + 2),
          const Text('Connection failed', style: AppTextStyles.caption),
        ]);
    }
  }

  Widget _buildAction(BuildContext context) {
    if (mailbox.syncStatus == MailboxSyncStatus.syncing) {
      return SizedBox(
        width: AppIconSize.md,
        height: AppIconSize.md,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.button1,
        ),
      );
    }
    if (mailbox.syncStatus == MailboxSyncStatus.error) {
      return GestureDetector(
        onTap: onRetry,
        child:
            Icon(Icons.refresh, color: context.button1, size: AppIconSize.md),
      );
    }
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Icon(Icons.more_vert, color: context.text3, size: AppIconSize.md),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.card1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.x5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.x5),
            Text(mailbox.email,
                style: AppTextStyles.bodyL.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.text1,
                )),
            const SizedBox(height: AppSpacing.x4),
            ListTile(
              leading: Icon(Icons.sync,
                  color: context.button1, size: AppIconSize.md),
              title: Text('Sync Now',
                  style: AppTextStyles.bodyM.copyWith(
                    color: context.text1,
                  )),
              onTap: () {
                Navigator.pop(context);
                onRetry();
              },
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: Colors.red, size: AppIconSize.md),
              title: Text('Remove Mailbox',
                  style: AppTextStyles.bodyM.copyWith(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onRemove();
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.x3),
          ],
        ),
      ),
    );
  }

  IconData get _providerIcon {
    switch (mailbox.provider) {
      case MailboxProvider.gmail:
        return Icons.mail_outline;
      case MailboxProvider.outlook:
        return Icons.email_outlined;
      case MailboxProvider.imap:
        return Icons.dns_outlined;
    }
  }
}
