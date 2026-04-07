import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/task/domain/entities/task_comment.dart';
import 'package:task_tracking_mobile/features/task/domain/repositories/task_item_repository.dart';

class TaskCommentController extends GetxController {
  final RxList<TaskComment> currentTaskComments = <TaskComment>[].obs;
  final RxBool commentsLoading = false.obs;
  final TextEditingController commentTextController = TextEditingController();
  final RxBool isSendingComment = false.obs;
  final RxInt isSelectedTab = 0.obs;

  @override
  void onClose() {
    commentTextController.dispose();
    super.onClose();
  }

  Future<void> fetchTaskComments(String taskItemId) async {
    commentsLoading.value = true;
    try {
      final repo = Get.find<TaskItemRepository>();
      final result = await repo.fetchTaskComments(taskItemId);
      currentTaskComments.assignAll(result);
    } catch (_) {
      currentTaskComments.clear();
    } finally {
      commentsLoading.value = false;
    }
  }

  Future<void> submitComment(String taskItemId) async {
    final content = commentTextController.text.trim();
    if (content.isEmpty) return;
    isSendingComment.value = true;
    try {
      final repo = Get.find<TaskItemRepository>();
      await repo.createTaskComment(taskItemId, content: content);
      commentTextController.clear();
      await fetchTaskComments(taskItemId);
    } finally {
      isSendingComment.value = false;
    }
  }
}
