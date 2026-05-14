import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/language_controller.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

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

  void _openLanguagePicker(BuildContext context) {
    final langCtrl = Get.find<LanguageController>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LanguagePickerSheet(
        isDark: isDark,
        isKhmer: langCtrl.isKhmer.value,
        onSelected: (selectKhmer) {
          if (langCtrl.isKhmer.value != selectKhmer) {
            langCtrl.toggleLanguage();
          }
          Get.back();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = Get.find<LanguageController>();
    return Obx(() {
      final isKhmer = langCtrl.isKhmer.value;
      final activeFlag = isKhmer ? _kKhFlag : _kEnFlag;
      final activeCode = isKhmer ? _kKhCode : _kEnCode;
      final activeName = isKhmer ? 'ខ្មែរ' : 'English';
      final secondaryText = isKhmer ? 'Switch to English' : 'ប្តូរទៅខ្មែរ';

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openLanguagePicker(context),
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1D2433), const Color(0xFF111827)]
                    : [Colors.white, const Color(0xFFF8FAFC)],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: kPrimary.withValues(alpha: isDark ? 0.22 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.language_rounded,
                    size: 18,
                    color: kPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeCode,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : kTextDark,
                        letterSpacing: kLs(0.25),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      secondaryText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white60 : kTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        activeName,
                        key: ValueKey(activeName),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : kTextDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeFlag,
                      style: const TextStyle(fontSize: 18, height: 1),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: isDark ? Colors.white54 : kTextMuted,
                ),
              ],
            ),
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
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FlagSegment(
              label: 'English',
              flag: _kEnFlag,
              isSelected: !isKhmer,
              isDark: isDark,
              onTap: () {
                if (isKhmer) langCtrl.toggleLanguage();
              },
            ),
            const SizedBox(width: 4),
            _FlagSegment(
              label: 'ខ្មែរ',
              flag: _kKhFlag,
              isSelected: isKhmer,
              isDark: isDark,
              onTap: () {
                if (!isKhmer) langCtrl.toggleLanguage();
              },
            ),
          ],
        ),
      );
    });
  }
}

class _FlagSegment extends StatelessWidget {
  const _FlagSegment({
    required this.label,
    required this.flag,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final String flag;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? kPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.24),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : kPrimary.withValues(alpha: isDark ? 0.12 : 0.08),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 12.5, height: 1),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : kTextDark),
                  letterSpacing: kLs(0.15),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet({
    required this.isDark,
    required this.isKhmer,
    required this.onSelected,
  });

  final bool isDark;
  final bool isKhmer;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'choose_language'.tr,
              style: AppTextStyles.title(
                color: isDark ? Colors.white : kTextDark,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'select_language'.tr,
              style: AppTextStyles.subTitle(
                color: isDark ? Colors.white60 : kTextMuted,
              ),
            ),
            const SizedBox(height: 16),
            _LanguageOptionCard(
              flag: _kEnFlag,
              title: 'English',
              subtitle: 'Use the app in English',
              isSelected: !isKhmer,
              isDark: isDark,
              onTap: () => onSelected(false),
            ),
            const SizedBox(height: 10),
            _LanguageOptionCard(
              flag: _kKhFlag,
              title: 'ខ្មែរ',
              subtitle: 'ប្រើកម្មវិធីជាភាសាខ្មែរ',
              isSelected: isKhmer,
              isDark: isDark,
              onTap: () => onSelected(true),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String flag;
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? kPrimary.withValues(alpha: isDark ? 0.18 : 0.08)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? kPrimary.withValues(alpha: 0.25)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? kPrimary
                      : kPrimary.withValues(alpha: isDark ? 0.16 : 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 20, height: 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.subTitle(
                        color: isDark ? Colors.white : kTextDark,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.subTitle(
                        color: isDark ? Colors.white60 : kTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected ? kPrimary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? kPrimary
                        : (isDark ? Colors.white38 : Colors.black26),
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
