import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog_widget.dart';

/// Shared profile page used by all user roles (Employee, Manager, Admin).
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: ColoredBox(
        color: isDark ? kBgDark : kBgLight,
        child: CustomScrollView(
          slivers: [
            // ── Title ───────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
            ),

            // ── Profile header card ──────────────────────────────
            SliverPadding(
              padding: kPagePadding,
              sliver: SliverToBoxAdapter(
                child: Obx(() {
                  final auth = Get.find<AuthController>().currentAuth.value;
                  final profile = Get.find<AuthController>().profile.value;
                  final name = profile?.fullName ?? auth?.fullName ?? '';
                  final role = profile?.primaryRole ?? auth?.primaryRole ?? '';
                  final email = profile?.email ?? '';
                  final avatarLetter =
                      name.isNotEmpty ? name[0].toUpperCase() : '?';
                  return _ProfileHeader(
                    isDark: isDark,
                    name: name,
                    role: role,
                    email: email,
                    avatarLetter: avatarLetter,
                  );
                }),
              ),
            ),

            // ── Personal Info label ──────────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Personal Info',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
            ),

            // ── Personal Info card ───────────────────────────────
            SliverPadding(
              padding: kPageSectionPadding,
              sliver: SliverToBoxAdapter(
                child: Obx(() {
                  final auth = Get.find<AuthController>().currentAuth.value;
                  final profile = Get.find<AuthController>().profile.value;
                  return _InfoCard(
                    isDark: isDark,
                    phone: profile?.phoneNumber ?? auth?.phoneNumber ?? '',
                    placeOfBirth: profile?.placeOfBirth ?? '',
                    dateOfBirth: profile?.dateOfBirth,
                  );
                }),
              ),
            ),

            // ── Settings label ───────────────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
            ),

            // ── Settings card (theme toggle) ─────────────────────
            SliverPadding(
              padding: kPageSectionPadding,
              sliver: SliverToBoxAdapter(
                child: _SettingsCard(isDark: isDark),
              ),
            ),

            // ── Account label ────────────────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
            ),

            // ── Account actions card ─────────────────────────────
            SliverPadding(
              padding: kPageSectionPadding,
              sliver: SliverToBoxAdapter(
                child: _ActionCard(isDark: isDark),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
    );
  }
}

// ── Profile Header ─────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.isDark,
    required this.name,
    required this.role,
    required this.email,
    required this.avatarLetter,
  });

  final bool isDark;
  final String name;
  final String role;
  final String email;
  final String avatarLetter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: kContentPaddingLarge,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kPrimary.withAlpha(30),
                  border: Border.all(color: kPrimary.withAlpha(80), width: 2),
                ),
                child: Center(
                  child: Text(
                    avatarLetter,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: kPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name.isEmpty ? '—' : name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : kTextDark,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: kPrimary.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role.isEmpty ? '—' : role,
              style: const TextStyle(
                fontSize: 12,
                color: kPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              email,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[500] : kTextMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Personal Info Card ─────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.isDark,
    required this.phone,
    required this.placeOfBirth,
    required this.dateOfBirth,
  });

  final bool isDark;
  final String phone;
  final String placeOfBirth;
  final DateTime? dateOfBirth;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.phone_rounded,
        'Phone',
        phone.isEmpty ? '—' : phone,
        const Color(0xFF2ED573),
      ),
      (
        Icons.location_on_rounded,
        'Place of Birth',
        placeOfBirth.isEmpty ? '—' : placeOfBirth,
        const Color(0xFFFFA502),
      ),
      (
        Icons.calendar_today_rounded,
        'Date of Birth',
        dateOfBirth != null
            ? '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}'
            : '—',
        const Color(0xFF6C63FF),
      ),
    ];

    return _Card(
      isDark: isDark,
      child: Column(
        children: List.generate(items.length, (i) {
          final (icon, label, value, color) = items[i];
          return _InfoRow(
            isDark: isDark,
            icon: icon,
            iconColor: color,
            label: label,
            value: value,
            showDivider: i < items.length - 1,
          );
        }),
      ),
    );
  }
}

// ── Settings Card ──────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    return _Card(
      isDark: isDark,
      child: Obx(
        () => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kPrimary.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  themeCtrl.isDark
                      ? Icons.wb_sunny_rounded
                      : Icons.nightlight_round,
                  color: kPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : kTextDark,
                  ),
                ),
              ),
              Switch(
                value: themeCtrl.isDark,
                onChanged: (_) => themeCtrl.toggle(),
                activeColor: kPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Account Actions Card ───────────────────────────────────────
class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _Card(
      isDark: isDark,
      child: Column(
        children: [
          _ActionRow(
            isDark: isDark,
            icon: Icons.lock_outline_rounded,
            iconColor: const Color(0xFF6C63FF),
            label: 'Change Password',
            onTap: () => _showChangePasswordSheet(context),
            showDivider: true,
          ),
          _ActionRow(
            isDark: isDark,
            icon: Icons.logout_rounded,
            iconColor: kHighPriority,
            label: 'Sign Out',
            labelColor: kHighPriority,
            onTap: () async {
              final confirmed = await showConfirmDeleteDialog(
                context,
                title: 'Sign Out',
                message: 'Are you sure you want to sign out?',
                confirmText: 'Sign Out',
              );
              if (confirmed == true) Get.find<AuthController>().logout();
            },
            showDivider: false,
          ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangePasswordSheet(isDark: isDark),
    );
  }
}

// ── Change Password Bottom Sheet ───────────────────────────────
class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet({required this.isDark});

  final bool isDark;

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String _error = '';

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentCtrl.text.trim();
    final newPass = _newCtrl.text;
    final confirm = _confirmCtrl.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'All fields are required.');
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = 'New passwords do not match.');
      return;
    }

    final passRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};:,.<>?]).{8,}$');
    if (!passRegex.hasMatch(newPass)) {
      setState(() => _error =
          'Password must be at least 8 characters and include uppercase, lowercase, number, and special character (e.g. Broya@168).');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      await Get.find<AuthController>().changePassword(
        currentPassword: current,
        newPassword: newPass,
        confirmNewPassword: confirm,
      );
      if (mounted) {
        Get.back();
        Get.snackbar(
          'Success',
          'Password changed successfully.',
          backgroundColor: const Color(0xFF2ED573),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final bg = isDark ? kCardDark : Colors.white;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Change Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : kTextDark,
              ),
            ),
            const SizedBox(height: 20),
            _PasswordField(
              controller: _currentCtrl,
              label: 'Current Password',
              isDark: isDark,
              obscure: _obscureCurrent,
              onToggle: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 14),
            _PasswordField(
              controller: _newCtrl,
              label: 'New Password',
              isDark: isDark,
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 14),
            _PasswordField(
              controller: _confirmCtrl,
              label: 'Confirm New Password',
              isDark: isDark,
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _error,
                style: const TextStyle(color: kHighPriority, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Update Password',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.isDark,
    required this.obscure,
    required this.onToggle,
  });

  final TextEditingController controller;
  final String label;
  final bool isDark;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: isDark ? Colors.white : kTextDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white54 : kTextMuted),
        filled: true,
        fillColor: isDark ? kBgDark : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 20,
            color: isDark ? Colors.white38 : Colors.grey.shade400,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? kCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.showDivider,
  });

  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[600] : kTextMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : kTextDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 66,
            color: isDark
                ? Colors.white.withAlpha(15)
                : Colors.black.withAlpha(10),
          ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    required this.showDivider,
    this.labelColor,
  });

  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: labelColor ?? (isDark ? Colors.white : kTextDark),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 66,
            color: isDark
                ? Colors.white.withAlpha(15)
                : Colors.black.withAlpha(10),
          ),
      ],
    );
  }
}