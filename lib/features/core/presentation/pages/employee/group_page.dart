import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/group/group_card_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/group/group_dialog.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<GroupController>();
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
          'group_title'.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : kTextDark,
          ),
        ),
      ),
      body: Obx(() {
        final groups = ctrl.groups;
        if (groups.isEmpty) {
          return RefreshIndicator(
            color: kPrimary,
            onRefresh: () => ctrl.fetchGroups(),
            child: ListView(
              children: [
                SizedBox(
                  height: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_outline_rounded,
                        size: 60,
                        color: isDark ? Colors.grey[700] : Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'group_no_groups'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[500] : kTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 600;

            final list = RefreshIndicator(
              color: kPrimary,
              onRefresh: () => ctrl.fetchGroups(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                itemCount: groups.length,
                itemBuilder: (_, i) {
                  final group = groups[i];
                  final count = ctrl.employeeCountByGroup(group.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GroupCardWidget(
                      isDark: isDark,
                      ctrl: ctrl,
                      group: group,
                      employeeCount: count,
                    ),
                  );
                },
              ),
            );

            if (isWide) {
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: list,
                ),
              );
            }

            return list;
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () => showGroupDialog(context, ctrl, isDark),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
