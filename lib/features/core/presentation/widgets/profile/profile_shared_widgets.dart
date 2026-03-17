import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_form_field.dart';

// ── Card container ─────────────────────────────────────────────
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.isDark, required this.child});

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

// ── Info row (label + value) ───────────────────────────────────
class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    super.key,
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
              Icon(icon, size: 20, color: iconColor),
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
            indent: 48,
            color: isDark
                ? Colors.white.withAlpha(15)
                : Colors.black.withAlpha(10),
          ),
      ],
    );
  }
}

// ── Action row (tappable) ──────────────────────────────────────
class ProfileActionRow extends StatelessWidget {
  const ProfileActionRow({
    super.key,
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
                Icon(icon, size: 20, color: iconColor),
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
            indent: 48,
            color: isDark
                ? Colors.white.withAlpha(15)
                : Colors.black.withAlpha(10),
          ),
      ],
    );
  }
}

// ── Password text field ────────────────────────────────────────
class PasswordFieldWidget extends StatelessWidget {
  const PasswordFieldWidget({
    super.key,
    required this.controller,
    required this.label,
    required this.isDark,
    required this.obscure,
    required this.onToggle,
    this.hasError = false,
  });

  final TextEditingController controller;
  final String label;
  final bool isDark;
  final bool obscure;
  final VoidCallback onToggle;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final decoration = loginInputDecoration(
      hint: label,
      icon: Icons.lock_outline_rounded,
      isDark: isDark,
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: kTextMuted,
        ),
        onPressed: onToggle,
      ),
    );

    return LoginFormField(
      label: label,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(
          color: isDark ? Colors.white : kTextDark,
          fontSize: 15,
        ),
        decoration: hasError
            ? decoration.copyWith(
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: kHighPriority),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: kHighPriority, width: 1.5),
                ),
              )
            : decoration,
      ),
    );
  }
}
