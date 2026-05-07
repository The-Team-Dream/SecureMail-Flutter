import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:securemail/core/router/app_router.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/features/mailbox_detail/screens/SecurityReportScreen.dart';
import 'package:securemail/features/mailbox_detail/widgets/mailbox_side_drawer.dart';
import 'package:securemail/core/mock/mock_data.dart';
// ── Data Models ────────────────────────────────────────────

enum IncidentType { criticalThreat, suspiciousActivity, systemUpdate }

class ReportIncident {
  const ReportIncident({
    required this.id, // ← الـ ID اللي هيتبعت للـ API
    required this.type,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.avatarInitials = const [],
    this.location,
    this.resolvedLabel,
    this.isRead = false,
  });

  final String id;
  final IncidentType type;
  final String title;
  final String description;
  final String timeAgo;
  final List<String> avatarInitials;
  final String? location;
  final String? resolvedLabel;
  final bool isRead;

  ReportIncident copyWith({bool? isRead}) => ReportIncident(
        id: id,
        type: type,
        title: title,
        description: description,
        timeAgo: timeAgo,
        avatarInitials: avatarInitials,
        location: location,
        resolvedLabel: resolvedLabel,
        isRead: isRead ?? this.isRead,
      );

  factory ReportIncident.fromJson(Map<String, dynamic> json) {
    return ReportIncident(
      id: json['id'] as String,
      type: IncidentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => IncidentType.systemUpdate,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      timeAgo: json['timeAgo'] as String,
      avatarInitials: (json['avatarInitials'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      location: json['location'] as String?,
      resolvedLabel: json['resolvedLabel'] as String?,
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

// ── Reports Screen ─────────────────────────────────────────

class ReportsScreen extends StatefulWidget {
  final int mailboxId;
  const ReportsScreen({
    super.key,
    required this.mailboxId,
    this.mailboxEmail = '',
    this.unreadCount,
  });

  final String mailboxEmail;
  final int? unreadCount;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _searchController = TextEditingController();
  String _activeFilter = 'All';
  String _query = '';
  late List<ReportIncident> _incidents;

  @override
  void initState() {
    super.initState();
    _incidents = MockData.mockIncidents
        .map((e) => ReportIncident.fromJson(e))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ReportIncident> get _filtered {
    var result = _incidents;

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      result = result.where((i) {
        return i.title.toLowerCase().contains(q) ||
            i.description.toLowerCase().contains(q);
      }).toList();
    }

    switch (_activeFilter) {
      case 'Unsecure':
        return result
            .where((i) =>
                i.type == IncidentType.criticalThreat ||
                i.type == IncidentType.suspiciousActivity)
            .toList();
      case 'Safe':
        return result
            .where((i) => i.type == IncidentType.systemUpdate)
            .toList();
      case 'Flagged':
        return result
            .where((i) => i.type == IncidentType.criticalThreat)
            .toList();
      default:
        return result;
    }
  }

  int get _criticalCount =>
      _incidents.where((i) => i.type == IncidentType.criticalThreat).length;

  int get _resolvedCount =>
      _incidents.where((i) => i.type == IncidentType.systemUpdate).length;

  int get _pendingCount =>
      _incidents.where((i) => i.type == IncidentType.suspiciousActivity).length;

  void _markAllRead() {
    setState(() {
      _incidents = _incidents.map((i) => i.copyWith(isRead: true)).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All incidents marked as read',
            style: AppTextStyles.bodyS.copyWith(color: Colors.white)),
        backgroundColor: context.button1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onReviewDetails(ReportIncident incident) {
    // علّم الـ incident كـ read
    setState(() {
      final idx = _incidents.indexOf(incident);
      if (idx != -1) {
        _incidents = List.from(_incidents)
          ..[idx] = incident.copyWith(isRead: true);
      }
    });

    // افتح شاشة التفاصيل وبعّت الـ ID للـ API
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SecurityReportScreen(incidentId: incident.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: context.bgColor,
      drawer: MailboxSideDrawer(
        activeRoute: AppRoutes.reports(widget.mailboxId),
        mailboxId: widget.mailboxId,
        mailboxEmail: widget.mailboxEmail,
        unreadCount: widget.unreadCount,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ReportsTopBar(
              searchController: _searchController,
              activeFilter: _activeFilter,
              onFilterChanged: (f) => setState(() => _activeFilter = f),
              onSearchChanged: (q) => setState(() => _query = q),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                children: [
                  _StatsRow(
                    critical: _criticalCount,
                    resolved: _resolvedCount,
                    pending: _pendingCount,
                  ),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    label: 'RECENT INCIDENTS',
                    action: 'Mark all read',
                    onActionTap: _markAllRead,
                  ),
                  const SizedBox(height: 14),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No incidents found',
                          style: AppTextStyles.bodyM
                              .copyWith(color: context.text3),
                        ),
                      ),
                    )
                  else
                    ...filtered.map(
                      (incident) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _IncidentCard(
                          incident: incident,
                          onReviewTap: () => _onReviewDetails(incident),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Bar ────────────────────────────────────────────────

class _ReportsTopBar extends StatelessWidget {
  const _ReportsTopBar({
    required this.searchController,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.barBg,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
            child: Row(
              children: [
                Builder(builder: (ctx) {
                  return IconButton(
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                    icon:
                        Icon(Icons.menu_rounded, color: context.text1, size: 24),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(40, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                }),
                const SizedBox(width: 6),
                Text(
                  'Reports',
                  style: AppTextStyles.displayS.copyWith(
                    color: context.text1,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _SearchField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                  ),
                ),
                const SizedBox(width: 12),
                const _ProfileAvatar(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: Row(
              children: [
                for (final label in ['All', 'Unsecure', 'Safe', 'Flagged']) ...[
                  if (label != 'All') const SizedBox(width: 8),
                  Expanded(
                    child: _FilterChip(
                      label: label,
                      selected: activeFilter == label,
                      onTap: () => onFilterChanged(label),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ──────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.critical,
    required this.resolved,
    required this.pending,
  });

  final int critical;
  final int resolved;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
              label: 'CRITICAL',
              value: critical.toString(),
              change: '+2%',
              changePositive: false),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
              label: 'RESOLVED',
              value: resolved.toString(),
              change: '-10%',
              changePositive: true),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
              label: 'PENDING',
              value: pending.toString(),
              change: '0%',
              changePositive: true),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.change,
    required this.changePositive,
  });

  final String label;
  final String value;
  final String change;
  final bool changePositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: context.text3,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppTextStyles.displayS.copyWith(
                    color: context.text1,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  change,
                  style: AppTextStyles.caption.copyWith(
                    color: changePositive
                        ? const Color(0xFF8CEB2F)
                        : const Color(0xFFFF5252),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.action,
    required this.onActionTap,
  });

  final String label;
  final String action;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.labelS.copyWith(
            color: context.text3,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onActionTap,
          child: Text(
            action,
            style: AppTextStyles.bodyS.copyWith(
              color: context.button1,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Incident Card ──────────────────────────────────────────

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({
    required this.incident,
    required this.onReviewTap,
  });

  final ReportIncident incident;
  final VoidCallback onReviewTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.card1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.fieldBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(child: _IncidentBadge(type: incident.type)),
              const SizedBox(width: 10),
              Text(
                incident.timeAgo,
                style: AppTextStyles.caption
                    .copyWith(color: context.text3, fontSize: 12),
              ),
              const Spacer(),
              _IncidentIcon(type: incident.type),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            incident.title,
            style: AppTextStyles.bodyL.copyWith(
              color: context.text1,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            incident.description,
            style: AppTextStyles.bodyS
                .copyWith(color: context.text3, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: context.text3.withValues(alpha: 0.15)),
          const SizedBox(height: 12),
          Row(
            children: [
              if (incident.avatarInitials.isNotEmpty) ...[
                _AvatarStack(initials: incident.avatarInitials),
                const SizedBox(width: 8),
              ],
              if (incident.location != null) ...[
                Icon(Icons.location_on_outlined, size: 14, color: context.text3),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    incident.location!,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption
                        .copyWith(color: context.text3, fontSize: 12),
                  ),
                ),
              ],
              if (incident.resolvedLabel != null) ...[
                Icon(Icons.check_circle_outline_rounded,
                    size: 14, color: const Color(0xFF8CEB2F)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    incident.resolvedLabel!,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF8CEB2F), fontSize: 12),
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: onReviewTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Review Details',
                      style: AppTextStyles.bodyS.copyWith(
                        color: context.button1,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded,
                        color: context.button1, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Incident Badge ─────────────────────────────────────────

class _IncidentBadge extends StatelessWidget {
  const _IncidentBadge({required this.type});

  final IncidentType type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      IncidentType.criticalThreat => ('CRITICAL THREAT', const Color(0xFFFF5252)),
      IncidentType.suspiciousActivity =>
        ('SUSPICIOUS ACTIVITY', const Color(0xFFF4D03F)),
      IncidentType.systemUpdate => ('SYSTEM UPDATE', const Color(0xFF8CEB2F)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.labelS.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Incident Icon ──────────────────────────────────────────

class _IncidentIcon extends StatelessWidget {
  const _IncidentIcon({required this.type});

  final IncidentType type;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      IncidentType.criticalThreat =>
        (Icons.radar_rounded, const Color(0xFF8CEB2F)),
      IncidentType.suspiciousActivity =>
        (Icons.storage_rounded, const Color(0xFFF4D03F)),
      IncidentType.systemUpdate =>
        (Icons.terminal_rounded, const Color(0xFF8CEB2F)),
    };
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

// ── Avatar Stack ───────────────────────────────────────────

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.initials});

  final List<String> initials;

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 26;
    const double overlap = 18;
    final double width = (initials.length - 1) * overlap + avatarSize;

    return SizedBox(
      width: width,
      height: avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < initials.length; i++)
            Positioned(
              left: i * overlap,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B2B23),
                  shape: BoxShape.circle,
                  border: Border.all(color: context.card1, width: 1.5),
                ),
                child: Text(
                  initials[i],
                  style: AppTextStyles.caption.copyWith(
                    color: context.button1,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Search Field ───────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 40),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodyM.copyWith(color: context.text1, height: 1),
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle:
              AppTextStyles.bodyM.copyWith(color: context.text3, height: 1),
          prefixIcon: Icon(Icons.search, color: context.text3, size: 20),
          filled: true,
          fillColor: context.fieldBg,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(color: context.button1),
          ),
        ),
      ),
    );
  }
}

// ── Filter Chip ────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? context.button1
              : context.button1.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.button1.withValues(alpha: 0.6)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelS.copyWith(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

// ── Profile Avatar ─────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(AppRoutes.profile),
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFD9FFF4),
          shape: BoxShape.circle,
          border: Border.all(color: context.button1, width: 2),
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.person, color: context.button1),
          ),
        ),
      ),
    );
  }
}