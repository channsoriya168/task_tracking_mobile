import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/core/widgets/no_internet_dialog.dart';
import 'package:task_tracking_mobile/core/widgets/offline_card_widget.dart';
import 'package:task_tracking_mobile/features/group/presentation/controllers/group_controller.dart';
import 'package:task_tracking_mobile/features/group/presentation/widgets/group_card_widget.dart';
import 'package:task_tracking_mobile/features/group/presentation/widgets/group_dialog.dart';
import 'package:task_tracking_mobile/features/group/presentation/widgets/group_shimmer_widget.dart';

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

            return Column(
              children: [
                Obx(() {
                  final offline =
                      !Get.find<NetworkController>().isConnected.value;
                  if (!offline || ctrl.isOfflineDialogOpen.value)
                    return const SizedBox.shrink();
                  return OfflineCardWidget(isDark: isDark);
                }),
                Expanded(
                  child: Obx(() {
                    final groups = ctrl.groups;
                    final offline =
                        !Get.find<NetworkController>().isConnected.value;

                    if (ctrl.isLoading.value || (offline && groups.isEmpty)) {
                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: 6,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, _) =>
                            GroupShimmerWidget(isDark: isDark),
                      );
                    }

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
                                    style: AppTextStyles.subTitle(
                                      color: isDark
                                          ? Colors.grey[600]
                                          : Colors.grey[400],
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
                      final cardWidth =
                          (constraints.maxWidth - 24 * 2 - 16) / 2;
                      return RefreshIndicator(
                        color: kPrimary,
                        onRefresh: () => ctrl.fetchGroups(),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
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
                        padding: const EdgeInsets.all(12),
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
                  }),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () {
          if (!Get.find<NetworkController>().isConnected.value) {
            ctrl.isOfflineDialogOpen.value = true;
            showNoInternetDialog(
              isDark: isDark,
            ).then((_) => ctrl.isOfflineDialogOpen.value = false);
            return;
          }
          showGroupDialog(
            context,
            ctrl,
            isDark,
            null,
            ctrl.isOfflineDialogOpen,
          );
        },
        label: Text('group_create_btn'.tr),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }
}
