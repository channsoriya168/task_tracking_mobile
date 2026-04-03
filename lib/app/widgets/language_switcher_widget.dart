import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/controllers/language_controller.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

// ── Language data ─────────────────────────────────────────────────────────────
const _kEnFlag = '🇬🇧';
const _kKhFlag = '🇰🇭';
const _kEnCode = 'EN';
const _kKhCode = 'ខ្មែរ';

// ── Login pill ────────────────────────────────────────────────────────────────

/// Compact flag pill for the login page top bar.
/// Shows the active flag + language code. Taps to switch.
class LanguageSwitcherPill extends StatelessWidget {
  const LanguageSwitcherPill({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final langCtrl = Get.find<LanguageController>();
    return Obx(() {
      final isKhmer = langCtrl.isKhmer.value;
      final flag = isKhmer ? _kKhFlag : _kEnFlag;
      final code = isKhmer ? _kKhCode : _kEnCode;

      return GestureDetector(
        onTap: langCtrl.toggleLanguage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withAlpha(20)
                : Colors.white.withAlpha(200),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(35)
                  : kPrimary.withAlpha(45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 30 : 12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flag
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  flag,
                  key: ValueKey(flag),
                  style: const TextStyle(fontSize: 18, height: 1),
                ),
              ),
              const SizedBox(width: 7),
              // Language code
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  code,
                  key: ValueKey(code),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : kTextDark,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.unfold_more_rounded,
                size: 14,
                color: isDark ? Colors.white38 : kTextMuted,
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Profile segment ───────────────────────────────────────────────────────────

/// Segmented flag selector for profile settings.
/// Shows 🇬🇧 EN | 🇰🇭 ខ្មែរ — the active one is highlighted.
class LanguageSwitcherSegment extends StatelessWidget {
  const LanguageSwitcherSegment({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final langCtrl = Get.find<LanguageController>();
    return Obx(() {
      final isKhmer = langCtrl.isKhmer.value;
      return Container(
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(10) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(18) : Colors.grey.shade200,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FlagSegment(
                flag: _kEnFlag,
                code: _kEnCode,
                isSelected: !isKhmer,
                isDark: isDark,
                isFirst: true,
                onTap: () {
                  if (isKhmer) langCtrl.toggleLanguage();
                },
              ),
              Container(
                width: 1,
                height: 22,
                color: isDark ? Colors.white10 : Colors.grey.shade300,
              ),
              _FlagSegment(
                flag: _kKhFlag,
                code: _kKhCode,
                isSelected: isKhmer,
                isDark: isDark,
                isFirst: false,
                onTap: () {
                  if (!isKhmer) langCtrl.toggleLanguage();
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _FlagSegment extends StatelessWidget {
  const _FlagSegment({
    required this.flag,
    required this.code,
    required this.isSelected,
    required this.isDark,
    required this.isFirst,
    required this.onTap,
  });

  final String flag;
  final String code;
  final bool isSelected;
  final bool isDark;
  final bool isFirst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(11) : Radius.zero,
            right: !isFirst ? const Radius.circular(11) : Radius.zero,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kPrimary.withAlpha(70),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: TextStyle(
                fontSize: 16,
                height: 1,
                // Slightly dim inactive flag
                color: isSelected
                    ? null
                    : Colors.black.withAlpha(isDark ? 100 : 160),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              code,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white38 : kTextMuted),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
