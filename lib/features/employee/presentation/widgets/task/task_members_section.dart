import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/user_avatar_widget.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_member.dart';
import 'package:task_tracking_mobile/features/employee/presentation/controllers/task_member_controller.dart';

// ── Members section ───────────────────────────────────────────────────────────

class TaskMembersSection extends StatelessWidget {
  const TaskMembersSection({
    super.key,
    required this.ctrl,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.canEdit,
    required this.onAdd,
    required this.onRemove,
  });

  final TaskMemberController ctrl;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final bool canEdit;
  final void Function(List<TaskMember>) onAdd;
  final void Function(TaskMember) onRemove;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final members = ctrl.currentTaskMembers.toList();
      final loading = ctrl.membersLoading.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.group_outlined, size: 16, color: mutedColor),
              const SizedBox(width: 8),
              Text('Members',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              const Spacer(),
              if (canEdit)
                GestureDetector(
                  onTap: () => onAdd(members),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: kPrimary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: kPrimary.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.add, size: 16, color: kPrimary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (loading)
            const Center(
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (members.isEmpty)
            Text(
              canEdit ? 'No members yet. Tap + to add.' : 'No members.',
              style: TextStyle(fontSize: 13, color: mutedColor),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: members
                  .map((m) => TaskMemberAvatar(
                      member: m,
                      isDark: isDark,
                      canEdit: canEdit,
                      onRemove: () => onRemove(m)))
                  .toList(),
            ),
        ],
      );
    });
  }
}

// ── Member avatar ─────────────────────────────────────────────────────────────

class TaskMemberAvatar extends StatelessWidget {
  const TaskMemberAvatar(
      {super.key,
      required this.member,
      required this.isDark,
      required this.canEdit,
      required this.onRemove});

  final TaskMember member;
  final bool isDark;
  final bool canEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            UserAvatarWidget(
              name: member.employeeName,
              imageUrl: member.employeeProfileImageUrl,
              radius: 21,
            ),
            if (canEdit)
              Positioned(
                top: -4,
                right: -4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: isDark ? kCardDark : Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child:
                        const Icon(Icons.close, size: 10, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 48,
          child: Text(
            member.employeeName.split(' ').first,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white60 : kTextMuted),
          ),
        ),
      ],
    );
  }
}
