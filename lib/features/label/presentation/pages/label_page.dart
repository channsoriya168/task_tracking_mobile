import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/core/widgets/no_internet_dialog.dart';
import 'package:task_tracking_mobile/core/widgets/offline_card_widget.dart';
import 'package:task_tracking_mobile/features/label/presentation/controllers/label_controller.dart';
import 'package:task_tracking_mobile/features/label/presentation/widgets/label_dialog.dart';
import 'package:task_tracking_mobile/features/label/presentation/widgets/label_shimmer_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/confirm_delete_dialog.dart';

enum _AdminLabelMenuAction { edit, delete }

// Hides the offline banner while the no-internet dialog is open so it
// doesn't show through behind the dialog barrier.
final _dialogOpen = false.obs;

class LabelPage extends StatelessWidget {
  const LabelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LabelController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuBgColor = isDark ? kCardDark : Colors.white;
    final menuBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final menuShadowColor = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.12);
    final menuTextColor = isDark ? Colors.white : kTextDark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      appBar: AppBar(
        backgroundColor: isDark ? kBgDark : kBgLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : kTextDark,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'labels'.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : kTextDark,
          ),
        ),
      ),
      body: Column(
        children: [
          // Offline banner — hidden while the no-internet dialog is showing
          Obx(() {
            final offline =
                !Get.find<NetworkController>().isConnected.value;
            if (!offline || _dialogOpen.value) return const SizedBox.shrink();
            return const OfflineCardWidget();
          }),
          Expanded(
            child: Obx(() {
              final offline =
                  !Get.find<NetworkController>().isConnected.value;

              if (ctrl.isLoading.value || (offline && ctrl.labels.isEmpty)) {
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  itemCount: 6,
                  separatorBuilder: (_, i) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => LabelShimmerWidget(isDark: isDark),
                );
              }

              if (ctrl.labels.isEmpty) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    decoration: BoxDecoration(
                      color: isDark ? kCardDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE5E7EB),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: kPrimary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.label_outline_rounded,
                            size: 30,
                            color: kPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_labels_get'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : kTextDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'label_empty_hint'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: isDark ? Colors.grey[400] : kTextMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              if (!Get.find<NetworkController>()
                                  .isConnected
                                  .value) {
                                _dialogOpen.value = true;
                                showNoInternetDialog(isDark: isDark)
                                    .then((_) => _dialogOpen.value = false);
                                return;
                              }
                              showLabelDialog(context, ctrl, isDark, null, _dialogOpen);
                            },
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text('labels'.tr),
                            style: FilledButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                    child: Row(
                      children: [
                        Text(
                          '${ctrl.labels.length} ${'labels'.tr}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : kTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
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
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            confirmDismiss: (_) => showConfirmDeleteDialog(
                              context,
                              title: 'label_delete_title'.tr,
                              content: 'label_delete_confirm'.trParams({
                                'name': label.name,
                              }),
                            ),
                            onDismissed: (_) => ctrl.deleteLabel(label.id),
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 14, 12, 14),
                              decoration: BoxDecoration(
                                color: isDark ? kCardDark : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFFE5E7EB),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.2 : 0.03,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                label.name,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark
                                                      ? Colors.white
                                                      : kTextDark,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (label.description != null &&
                                            label.description!
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            label.description!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              height: 1.35,
                                              color: isDark
                                                  ? Colors.grey[400]
                                                  : kTextMuted,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<_AdminLabelMenuAction>(
                                    icon: Icon(
                                      Icons.more_vert_rounded,
                                      color: isDark
                                          ? Colors.grey[300]
                                          : kTextMuted,
                                    ),
                                    color: menuBgColor,
                                    surfaceTintColor: Colors.transparent,
                                    elevation: 8,
                                    shadowColor: menuShadowColor,
                                    position: PopupMenuPosition.under,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      side:
                                          BorderSide(color: menuBorderColor),
                                    ),
                                    tooltip: 'actions'.tr,
                                    onSelected: (action) async {
                                      if (action ==
                                          _AdminLabelMenuAction.edit) {
                                        showLabelDialog(
                                            context, ctrl, isDark, label, _dialogOpen);
                                        return;
                                      }

                                      final confirmed =
                                          await showConfirmDeleteDialog(
                                        context,
                                        title: 'label_delete_title'.tr,
                                        content:
                                            'label_delete_confirm'.trParams({
                                          'name': label.name,
                                        }),
                                      );
                                      if (confirmed == true) {
                                        ctrl.deleteLabel(label.id);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      PopupMenuItem<_AdminLabelMenuAction>(
                                        value: _AdminLabelMenuAction.edit,
                                        height: 42,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.edit_rounded,
                                              size: 14,
                                              color: kMediumPriority,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'edit'.tr,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: menuTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<_AdminLabelMenuAction>(
                                        value: _AdminLabelMenuAction.delete,
                                        height: 42,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.delete_rounded,
                                              size: 14,
                                              color: kHighPriority,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'delete'.tr,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: kHighPriority,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: () {
          if (!Get.find<NetworkController>().isConnected.value) {
            _dialogOpen.value = true;
            showNoInternetDialog(isDark: isDark)
                .then((_) => _dialogOpen.value = false);
            return;
          }
          showLabelDialog(context, ctrl, isDark, null, _dialogOpen);
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

