import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/core/widgets/user_avatar_widget.dart';

// ── Label chip ────────────────────────────────────────────────────────────────

class TaskLabelChip extends StatelessWidget {
  const TaskLabelChip({
    super.key,
    required this.name,
    required this.color,
    required this.isDark,
  });
  final String name;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Assignee row ──────────────────────────────────────────────────────────────

class TaskAssigneeRow extends StatelessWidget {
  const TaskAssigneeRow({
    super.key,
    required this.name,
    required this.isDark,
    this.imageUrl,
  });
  final String name;
  final bool isDark;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatarWidget(name: name, imageUrl: imageUrl, radius: 14),
        const SizedBox(width: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : kTextDark,
          ),
        ),
      ],
    );
  }
}

// ── Sheet button ──────────────────────────────────────────────────────────────

class TaskSheetButton extends StatelessWidget {
  const TaskSheetButton({
    super.key,
    required this.label,
    required this.isDark,
    required this.onPressed,
  });
  final String label;
  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(
          color: isDark ? Colors.white24 : Colors.black.withValues(alpha: 0.15),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : kTextMuted,
        ),
      ),
    );
  }
}

// ── Transition button ─────────────────────────────────────────────────────────

class TaskTransitionButton extends StatelessWidget {
  const TaskTransitionButton({
    super.key,
    required this.label,
    required this.color,
    required this.isDark,
    required this.loading,
    required this.onTap,
    this.width,
  });

  final String label;
  final Color color;
  final bool isDark;
  final bool loading;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = color.withValues(alpha: isDark ? 0.16 : 0.10);
    final borderColor = color.withValues(alpha: isDark ? 0.30 : 0.22);
    final textColor = isDark ? Colors.white : color;
    final spinnerColor = isDark ? Colors.white : color;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shadowColor: color.withValues(alpha: 0.10),
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: loading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 24,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: spinnerColor,
                  ),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: AppTextStyles.buttonLabel(color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Detail row ────────────────────────────────────────────────────────────────

class TaskDetailRow extends StatelessWidget {
  const TaskDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
    required this.child,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mutedColor = isDark ? Colors.white38 : kTextMuted;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: mutedColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(label, style: TextStyle(fontSize: 13, color: mutedColor)),
        ),
        Expanded(child: child),
      ],
    );
  }
}
