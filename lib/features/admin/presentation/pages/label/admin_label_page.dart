import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/controllers/admin_label_controller.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_label_dialog.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/action_button.dart';
import 'package:task_tracking_mobile/features/manager/presentation/widgets/confirm_delete_dialog.dart';

class AdminLabelPage extends StatelessWidget {
  const AdminLabelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminLabelController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: AppBar(
        backgroundColor: isDark ? kBgDark : kBgLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : kTextDark,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Labels',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : kTextDark,
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.labels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.label_outline_rounded,
                  size: 60,
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No labels yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[500] : kTextMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to create your first label',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[600] : kTextMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: ctrl.labels.length,
          itemBuilder: (_, i) {
            final label = ctrl.labels[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey(label.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: kHighPriority.withAlpha(200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                confirmDismiss: (_) => showConfirmDeleteDialog(
                  context,
                  title: 'Delete Label',
                  content: 'Delete label "${label.name}"?',
                ),
                onDismissed: (_) => ctrl.deleteLabel(label.id),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? kCardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: kPrimary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.label_rounded,
                              size: 12,
                              color: kPrimary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              label.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (label.description != null &&
                          label.description!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[500] : kTextMuted,
                            ),
                          ),
                        ),
                      ] else
                        const Spacer(),
                      const SizedBox(width: 8),
                      ActionButton(
                        icon: Icons.edit_rounded,
                        color: kMediumPriority,
                        onTap: () => showAdminLabelDialog(
                          context,
                          ctrl,
                          isDark,
                          label,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ActionButton(
                        icon: Icons.delete_rounded,
                        color: kHighPriority,
                        onTap: () async {
                          final confirmed = await showConfirmDeleteDialog(
                            context,
                            title: 'Delete Label',
                            content: 'Delete label "${label.name}"?',
                          );
                          if (confirmed == true) ctrl.deleteLabel(label.id);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () => showAdminLabelDialog(context, ctrl, isDark),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
