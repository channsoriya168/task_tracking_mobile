import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/group/presentation/widgets/group_card_widget.dart';
import 'package:task_tracking_mobile/features/group/presentation/widgets/group_dialog.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<GroupController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: AppBar(
        backgroundColor: isDark ? kBgDark : kBgLight,
        elevation: 0,
        toolbarHeight: isTablet ? 64 : kToolbarHeight,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : kTextDark,
            size: isTablet ? 22 : 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'group_title'.tr,
          style: AppTextStyles.appBarTitle(color: kPrimary),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTabletLayout = constraints.maxWidth >= 600;

            return Obx(() {
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
                              size: isTabletLayout ? 80 : 60,
                              color: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'group_no_groups'.tr,
                              style: TextStyle(
                                fontSize: isTabletLayout ? 18 : 16,
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

              if (isTabletLayout) {
                final cardWidth = (constraints.maxWidth - 24 * 2 - 16) / 2;
                return RefreshIndicator(
                  color: kPrimary,
                  onRefresh: () => ctrl.fetchGroups(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final group in groups)
                          SizedBox(
                            width: cardWidth,
                            child: GroupCardWidget(
                              isDark: isDark,
                              ctrl: ctrl,
                              group: group,
                              employeeCount: ctrl.employeeCountByGroup(
                                group.id,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
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
            });
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () => showGroupDialog(context, ctrl, isDark),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
