import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/notification/domain/entities/notification_entity.dart';
import 'package:task_tracking_mobile/features/notification/domain/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository;

  NotificationController(this._repository);

  final RxList<NotificationEntity> notifications = <NotificationEntity>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();
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
    try {
      await _repository.markAsRead(notificationId);
      // Optimistic update
      final idx = notifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        final old = notifications[idx];
        if (!old.isRead) {
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
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to mark notification as read.',
        backgroundColor: const Color(0xFFFF4757),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      // Optimistic update
      notifications.assignAll(
        notifications.map(
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
        ),
      );
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
}
