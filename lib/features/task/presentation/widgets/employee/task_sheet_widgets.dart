import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/user_avatar_widget.dart';

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
    required this.loading,
    required this.onTap,
    this.width,
  });

  final String label;
  final Color color;
  final bool loading;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(
                width: 24,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
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
