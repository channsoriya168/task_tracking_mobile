import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final bool highlighted;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = highlighted
        ? const Color(0xFF4CAF50)
        : (isDark ? kCardDark : Colors.white);
    final Color titleColor =
        highlighted ? Colors.white : (isDark ? Colors.white : kTextDark);
    final Color mutedColor = highlighted
        ? Colors.white.withOpacity(0.75)
        : (isDark ? Colors.white54 : kTextMuted);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: kHighPriority.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: kHighPriority),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title + more button ─────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showMenu(context),
                    child: Icon(Icons.more_horiz_rounded,
                        color: mutedColor, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Tags ────────────────────────────────────────
              Row(
                children: [
                  _priorityTag(highlighted),
                  const SizedBox(width: 6),
                  _categoryTag(highlighted, isDark),
                ],
              ),
              const SizedBox(height: 14),

              // ── Footer ──────────────────────────────────────
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 12, color: mutedColor),
                  const SizedBox(width: 4),
                  Text(
                    task.dueDate != null
                        ? _formatDate(task.dueDate!)
                        : 'No date',
                    style: TextStyle(fontSize: 12, color: mutedColor),
                  ),
                  const SizedBox(width: 14),
                  Icon(Icons.attach_file_rounded,
                      size: 12, color: mutedColor),
                  const SizedBox(width: 3),
                  Text('5', style: TextStyle(fontSize: 12, color: mutedColor)),
                  const SizedBox(width: 14),
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 12, color: mutedColor),
                  const SizedBox(width: 3),
                  Text('5', style: TextStyle(fontSize: 12, color: mutedColor)),
                  const Spacer(),
                  _avatarStack(cardBg),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? kSurfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined,
                  color: isDark ? Colors.white70 : kTextDark),
              title: Text('Edit',
                  style:
                      TextStyle(color: isDark ? Colors.white : kTextDark)),
              onTap: () {
                Navigator.pop(context);
                onTap();
              },
            ),
            ListTile(
              leading: Icon(Icons.check_circle_outline_rounded,
                  color: isDark ? Colors.white70 : kTextDark),
              title: Text(
                task.status == TaskStatus.done
                    ? 'Mark as To Do'
                    : 'Mark as Complete',
                style:
                    TextStyle(color: isDark ? Colors.white : kTextDark),
              ),
              onTap: () {
                Navigator.pop(context);
                onToggle();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline_rounded, color: kHighPriority),
              title: const Text('Delete',
                  style: TextStyle(color: kHighPriority)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Tag helpers ──────────────────────────────────────────

  Widget _priorityTag(bool highlighted) {
    Color bg, fg;
    if (highlighted) {
      bg = Colors.white.withOpacity(0.25);
      fg = Colors.white;
    } else {
      switch (task.priority) {
        case TaskPriority.high:
          bg = const Color(0xFFFFE4E4);
          fg = const Color(0xFFE53935);
          break;
        case TaskPriority.medium:
          bg = const Color(0xFFFFF3E0);
          fg = const Color(0xFFFB8C00);
          break;
        case TaskPriority.low:
          bg = const Color(0xFFE8F5E9);
          fg = const Color(0xFF43A047);
          break;
      }
    }
    return _pill(task.priorityLabel, bg, fg);
  }

  Widget _categoryTag(bool highlighted, bool isDark) {
    if (highlighted) {
      return _pill(
          task.category, Colors.black.withOpacity(0.2), Colors.white);
    }
    return _pill(task.category, _catBg(), _catFg());
  }

  Color _catBg() {
    switch (task.category) {
      case 'Meeting':       return const Color(0xFFE3F2FD);
      case 'Engineering':   return const Color(0xFFEDE7F6);
      case 'Design':        return const Color(0xFFFCE4EC);
      case 'Research':      return const Color(0xFFE0F7FA);
      case 'Documentation': return const Color(0xFFFFF8E1);
      case 'Marketing':     return const Color(0xFFF3E5F5);
      case 'Maintenance':   return const Color(0xFFECEFF1);
      default:              return const Color(0xFFF5F5F5);
    }
  }

  Color _catFg() {
    switch (task.category) {
      case 'Meeting':       return const Color(0xFF1976D2);
      case 'Engineering':   return const Color(0xFF6B3FA0);
      case 'Design':        return const Color(0xFFD81B60);
      case 'Research':      return const Color(0xFF00838F);
      case 'Documentation': return const Color(0xFFF57C00);
      case 'Marketing':     return const Color(0xFF8E24AA);
      case 'Maintenance':   return const Color(0xFF546E7A);
      default:              return kTextMuted;
    }
  }

  Widget _pill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _avatarStack(Color cardBg) {
    const colors = [
      Color(0xFF6C63FF),
      Color(0xFFFF6584),
      Color(0xFF43CBFF),
    ];
    return SizedBox(
      width: 52,
      height: 22,
      child: Stack(
        children: List.generate(
          3,
          (i) => Positioned(
            left: i * 16.0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
                border: Border.all(color: cardBg, width: 1.5),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + i),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${m[date.month - 1]} ${date.year}';
  }
}
