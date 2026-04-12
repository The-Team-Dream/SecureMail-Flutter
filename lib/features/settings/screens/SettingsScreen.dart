import 'package:flutter/material.dart';
import 'package:securemail/core/theme/app_color/contextExt.dart';
import 'package:securemail/core/theme/app_spacing/AppSpacing.dart';
import 'package:securemail/core/theme/app_text_styles/AppTextStyles.dart';

class Settingsscreen extends StatefulWidget {
  const Settingsscreen({super.key});

  @override
  State<Settingsscreen> createState() => _SettingsscreenState();
}

class _SettingsscreenState extends State<Settingsscreen> {
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.screenVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('PERSONAL'),
            const SizedBox(height: AppSpacing.x2),
            _buildCard(
              children: [
                _buildNavItem(
                  icon: Icons.manage_accounts_outlined,
                  title: 'Edit Profile',
                  subtitle: 'Update your name and profile photo',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Appearance ────────────────────────────────
            _buildSectionLabel('APPEARANCE'),
            const SizedBox(height: AppSpacing.x2),
            _buildCard(
              children: [
                _buildToggleItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Save battery and reduce strain',
                  value: _darkMode,
                  onChanged: (val) => setState(() => _darkMode = val),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Security ──────────────────────────────────
            _buildSectionLabel('SECURITY'),
            const SizedBox(height: AppSpacing.x2),
            _buildCard(
              children: [
                _buildNavItem(
                  icon: Icons.key_outlined,
                  title: 'Change Password',
                  subtitle: 'Last changed 3 months ago',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildNavItem(
                  icon: Icons.lock_outlined,
                  title: 'Two-Factor Auth',
                  subtitle: 'Enhanced account protection',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Session Management ────────────────────────
            _buildSectionLabel('SESSION MANAGEMENT'),
            const SizedBox(height: AppSpacing.x2),
            _buildCard(
              children: [
                _buildNavItem(
                  icon: Icons.devices_outlined,
                  title: 'Logged in Devices',
                  subtitle: '3 active sessions detected',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Preferences ───────────────────────────────
            _buildSectionLabel('PREFERENCES'),
            const SizedBox(height: AppSpacing.x2),
            _buildCard(
              children: [
                _buildNavItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Push, Email, and Security alerts',
                  onTap: () {},
                ),
                _buildDivider(),
                _buildNavItem(
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Encryption keys, Biometrics',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x6),

            // ── Clear Cache ───────────────────────────────
            _buildClearCacheCard(),
            const SizedBox(height: AppSpacing.x6),

            // ── Footer ────────────────────────────────────
            _buildFooter(),
            const SizedBox(height: AppSpacing.x8),
          ],
        ),
      ),
    );
  }

  // ── Section Label ─────────────────────────────────────────
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelS.copyWith(
        color: context.text3,
        letterSpacing: 1.5,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────
  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: context.card2,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.fieldBorder.withOpacity(0.3)),
      ),
      child: Column(children: children),
    );
  }

  // ── Nav Item ──────────────────────────────────────────────
  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x4,
          vertical: AppSpacing.x4,
        ),
        child: Row(
          children: [
            _buildIconBox(icon),
            const SizedBox(width: AppSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.bodyM.copyWith(
                          color: context.text1, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          AppTextStyles.bodyS.copyWith(color: context.text3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.text3, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Toggle Item ───────────────────────────────────────────
  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x4,
      ),
      child: Row(
        children: [
          _buildIconBox(icon),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyM.copyWith(
                        color: context.text1, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTextStyles.bodyS.copyWith(color: context.text3)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: context.button1,
            activeTrackColor: context.button1.withOpacity(0.3),
            inactiveThumbColor: context.text3,
            inactiveTrackColor: context.card3,
          ),
        ],
      ),
    );
  }

  // ── Icon Box ──────────────────────────────────────────────
  Widget _buildIconBox(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.button1.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: context.button1, size: 20),
    );
  }

  // ── Divider ───────────────────────────────────────────────
  Widget _buildDivider() {
    return Divider(
      color: context.fieldBorder.withOpacity(0.3),
      height: 1,
      indent: AppSpacing.x4 + 40 + AppSpacing.x3,
    );
  }

  // ── Clear Cache Card ──────────────────────────────────────
  Widget _buildClearCacheCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x4,
      ),
      decoration: BoxDecoration(
        color: context.card2,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.fieldBorder.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE24B4A).withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.delete_outline,
                color: Color(0xFFE24B4A), size: 20),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Clear Cache',
                    style: AppTextStyles.bodyM.copyWith(
                        color: const Color(0xFFE24B4A),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('124 MB of temporary data',
                    style: AppTextStyles.bodyS.copyWith(color: context.text3)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE24B4A),
              side: const BorderSide(color: Color(0xFFE24B4A)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x4, vertical: AppSpacing.x2),
              minimumSize: Size.zero, // ← أضف السطر ده
              tapTargetSize: MaterialTapTargetSize.shrinkWrap, // ←
            ),
            child: Text('Clear',
                style: AppTextStyles.labelS
                    .copyWith(color: const Color(0xFFE24B4A))),
          ),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────
  Widget _buildFooter() {
    return Column(
      children: [
        // Secure Protocol Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4, vertical: AppSpacing.x2),
            decoration: BoxDecoration(
              border: Border.all(color: context.button1.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: context.button1, shape: BoxShape.circle),
                ),
                const SizedBox(width: AppSpacing.x2),
                Text(
                  'SECURE PROTOCOL V3.4 ACTIVE',
                  style: AppTextStyles.labelS.copyWith(
                    color: context.button1,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
