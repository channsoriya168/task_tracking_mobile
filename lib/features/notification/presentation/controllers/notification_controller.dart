import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:task_tracking_mobile/core/controllers/network_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/enums/user_role.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/notification/domain/entities/notification_entity.dart';
import 'package:task_tracking_mobile/features/notification/domain/repositories/notification_repository.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';
import 'package:task_tracking_mobile/features/task/presentation/controllers/employee_task_controller.dart';
import 'package:task_tracking_mobile/features/task/presentation/widgets/task_bottom_sheet.dart';
import 'package:task_tracking_mobile/routes/app_routes.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository;

  NotificationController(this._repository);

  StreamSubscription<RemoteMessage>? _fcmSubscription;

  final RxList<NotificationEntity> notifications = <NotificationEntity>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool showUnreadOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();
    _fcmSubscription = FirebaseMessaging.onMessage.listen((_) {
      fetchNotifications();
      fetchUnreadCount();
    });

    // Auto-refresh when internet is restored.
    ever(Get.find<NetworkController>().connectionStatus, (status) {
      if (status == ConnectionStatus.reconnected) {
        fetchNotifications();
        fetchUnreadCount();
      }
    });
  }

  @override
  void onClose() {
    _fcmSubscription?.cancel();
    super.onClose();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _repository.getMyNotifications();
      notifications.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      unreadCount.value = await _repository.getUnreadCount();
    } catch (_) {
      // Silently fail — badge stays at current count
    }
  }

  Future<void> markAsRead(String notificationId) async {
    // Update locally first for instant UI feedback
    final idx = notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      final old = notifications[idx];
      if (old.isRead) return; // already read — nothing to do
      notifications[idx] = NotificationEntity(
        id: old.id,
        recipientId: old.recipientId,
        taskId: old.taskId,
        type: old.type,
        typeName: old.typeName,
        title: old.title,
        message: old.message,
        isRead: true,
        readAt: DateTime.now(),
        createdAt: old.createdAt,
      );
      unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
    }

    // Sync with backend (fire-and-forget; no revert on failure)
    try {
      await _repository.markAsRead(notificationId);
    } catch (_) {
      // silently ignore — local state already updated
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      // .toList() materialises the mapped values before assignAll clears the
      // underlying list — without it the lazy iterable maps over an empty list.
      final updated = notifications
          .map(
            (n) => NotificationEntity(
              id: n.id,
              recipientId: n.recipientId,
              taskId: n.taskId,
              type: n.type,
              typeName: n.typeName,
              title: n.title,
              message: n.message,
              isRead: true,
              readAt: n.readAt ?? DateTime.now(),
              createdAt: n.createdAt,
            ),
          )
          .toList();
      notifications.assignAll(updated);
      unreadCount.value = 0;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark all as read.',
        backgroundColor: const Color(0xFFFF4757),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.delete(notificationId);
      final removed = notifications.firstWhere((n) => n.id == notificationId);
      notifications.removeWhere((n) => n.id == notificationId);
      if (!removed.isRead) {
        unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete notification.',
        backgroundColor: const Color(0xFFFF4757),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> openTaskDetail(String taskId, {int initialTab = 0}) async {
    TaskItemRepository? repo;
    try {
      repo = Get.find<TaskItemRepository>();
    } catch (_) {
      Get.toNamed(AppRoutes.notifications);
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final task = await repo.fetchTaskItemById(taskId);
      if (Get.isDialogOpen ?? false) Get.back();

      final context = Get.context;
      if (context == null) return;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final role = Get.find<AuthController>().role;

      if (role == UserRole.employee) {
        if (Get.isRegistered<EmployeeTaskController>()) {
          Get.find<EmployeeTaskController>().prepareTaskDetail(taskId, initialTab: initialTab);
        }
        Get.toNamed(
          AppRoutes.taskDetail,
          arguments: {
            'task': task,
            'isDark': isDark,
            'readOnly': false,
            'initialTab': initialTab,
          },
        );
      } else {
        await TaskBottomSheet.showTaskDetailSheet(
          context,
          isDark,
          task,
          fetchDetail: repo.fetchTaskItemById,
        );
      }
    } catch (_) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Could not load task details.',
        backgroundColor: const Color(0xFFFF4757),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
