import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class ActionCardWidget extends StatelessWidget {
  const ActionCardWidget({
    super.key,
    this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onTap,
  });
  final bool? isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool _isDark =
        isDark ?? Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: _isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      kPrimary.withOpacity(_isDark ? 0.50 : 0.20),
                      kPrimary.withOpacity(_isDark ? 0.32 : 0.10),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: _isDark
                      ? Colors.white
                      : Colors.black.withOpacity(0.78),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.buttonLabel(
                        color: _isDark
                            ? Colors.white
                            : Colors.black.withOpacity(0.88),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption(
                        color: _isDark
                            ? Colors.white.withOpacity(0.65)
                            : Colors.black.withOpacity(0.56),
                      ),
                    ),
                  ],
                ),
              ),
              if (actionLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF2FBF71).withOpacity(0.92),
                        const Color(0xFF21A45F).withOpacity(0.92),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF21A45F).withOpacity(0.24),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    actionLabel!,
                    style: AppTextStyles.subTitle(color: Colors.white),
                  ),
                )
              else
                Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: _isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: _isDark
                        ? Colors.white.withOpacity(0.80)
                        : Colors.black.withOpacity(0.60),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
