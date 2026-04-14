import 'package:flutter/material.dart';
import 'package:securemail/core/mock/mock_data.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';
import 'package:securemail/shared/widgets/auth_gradient_background.dart';

class LoggedInDevicesScreen extends StatefulWidget {
  const LoggedInDevicesScreen({super.key});

  @override
  State<LoggedInDevicesScreen> createState() => _LoggedInDevicesScreenState();
}

class _LoggedInDevicesScreenState extends State<LoggedInDevicesScreen> {
  // Load sessions from mock data — replace with API call later
  late List<Map<String, dynamic>> _sessions;
  bool _isRevoking = false;

  @override
  void initState() {
    super.initState();
    _sessions = List<Map<String, dynamic>>.from(
      MockData.mockSessions.map((s) => Map<String, dynamic>.from(s)),
    );
  }

  Future<void> _revokeSession(int id) async {
    setState(() => _isRevoking = true);

    // TODO: استبدل بـ API call حقيقي
    // await ApiClient.instance.delete('/sessions/$id');
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() {
      _sessions.removeWhere((s) => s['id'] == id);
      _isRevoking = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Session revoked successfully.',
          style: AppTextStyles.bodyM.copyWith(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F8A70),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  Future<void> _revokeAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.card1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Log out of all sessions?',
          style: AppTextStyles.headingM.copyWith(color: context.text1),
        ),
        content: Text(
          'This will end all sessions except for the one you are currently using.',
          style: AppTextStyles.bodyM.copyWith(color: context.text3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.labelM.copyWith(color: context.text3)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Log out all',
                style: AppTextStyles.labelM
                    .copyWith(color: const Color(0xFFE24B4A))),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRevoking = true);
    // TODO: استبدل بـ API call حقيقي
    // await ApiClient.instance.delete('/sessions');
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() {
      _sessions = _sessions.where((s) => s['isCurrent'] == true).toList();
      _isRevoking = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'All other sessions have been revoked.',
          style: AppTextStyles.bodyM.copyWith(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F8A70),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logged In Devices'),
      ),
      body: AuthGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.screenVertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.x4),

                // ── Header ──────────────────────────────────
                Text(
                  'Active Sessions',
                  style: AppTextStyles.displayS.copyWith(color: context.text1),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.x2),
                Text(
                  'Review the devices currently signed into your SecureMail account. If you don\'t recognize a device, revoke its access immediately.',
                  style: AppTextStyles.bodyM.copyWith(color: context.text3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.x6),

                // ── Sessions List ────────────────────────────
                ..._sessions.map((session) => _buildSessionCard(session)),

                const SizedBox(height: AppSpacing.x6),

                // ── Revoke All Button ────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: AppSize.buttonHeightL,
                  child: ElevatedButton.icon(
                    onPressed: _isRevoking ? null : _revokeAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE24B4A),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFFE24B4A).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 0,
                    ),
                    icon: _isRevoking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.logout,
                            size: 18,
                            color: Colors.white,
                          ),
                    label: Text(
                      'Log out of all other sessions',
                      style: AppTextStyles.labelL.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.x2),
                Text(
                  'This will end all sessions except for the one you are currently using.',
                  style: AppTextStyles.bodyS.copyWith(color: context.text3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.x8),

                // ── Footer ──────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: context.text3),
                    const SizedBox(width: AppSpacing.x1),
                    Text(
                      'SECUREMAIL',
                      style: AppTextStyles.labelS.copyWith(
                        color: context.text3,
                        letterSpacing: 2,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final isCurrent = session['isCurrent'] == true;
    final os = session['deviceOs'] as String;
    final browser = session['deviceBrowser'] as String;
    final ip = session['ipAddress'] as String;
    final loginAt = session['loginAt'] as String;

    final deviceName = '$browser on $os';
    final lastActive = _formatDate(loginAt);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.x3),
      padding: const EdgeInsets.all(AppSpacing.x4),
      decoration: BoxDecoration(
        color: isCurrent ? context.button1.withOpacity(0.08) : context.card1,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isCurrent
              ? context.button1.withOpacity(0.4)
              : context.fieldBorder.withOpacity(0.3),
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Device Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.button1.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              _getDeviceIcon(os),
              color: context.button1,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.x3),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        deviceName,
                        style: AppTextStyles.bodyM.copyWith(
                          color: context.text1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.button1.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: context.button1.withOpacity(0.4)),
                        ),
                        child: Text(
                          'CURRENT',
                          style: AppTextStyles.caption.copyWith(
                            color: context.button1,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '$ip • $lastActive',
                  style: AppTextStyles.bodyS.copyWith(color: context.text3),
                ),
              ],
            ),
          ),

          // Revoke or "This device" label
          if (!isCurrent) ...[
            const SizedBox(width: AppSpacing.x2),
            OutlinedButton(
              onPressed: _isRevoking
                  ? null
                  : () => _revokeSession(session['id'] as int),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE24B4A),
                side: const BorderSide(color: Color(0xFFE24B4A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x3, vertical: AppSpacing.x2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Revoke',
                style: AppTextStyles.labelS
                    .copyWith(color: const Color(0xFFE24B4A)),
              ),
            ),
          ] else ...[
            const SizedBox(width: AppSpacing.x2),
            Text(
              'This device',
              style: AppTextStyles.bodyS.copyWith(
                color: context.button1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String os) {
    switch (os.toLowerCase()) {
      case 'android':
        return Icons.phone_android;
      case 'ios':
        return Icons.phone_iphone;
      case 'windows':
        return Icons.desktop_windows_outlined;
      case 'macos':
        return Icons.laptop_mac_outlined;
      default:
        return Icons.devices_outlined;
    }
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 5) return 'Active now';
      if (diff.inHours < 24) return 'Last active: ${diff.inHours}h ago';
      if (diff.inDays < 30) return 'Last active: ${diff.inDays} days ago';
      return 'Last active: ${dt.month}/${dt.day}/${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
