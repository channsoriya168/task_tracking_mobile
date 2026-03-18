import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_comment.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_item.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_member.dart';
import 'package:task_tracking_mobile/features/core/domain/entities/task_progress.dart';
import 'package:task_tracking_mobile/features/core/domain/repositories/task_item_repository.dart';

class TaskDetailController extends GetxController {
  TaskDetailController(this._repo, TaskItem initial) {
    task = initial.obs;
  }

  final TaskItemRepository? _repo;

  late final Rx<TaskItem> task;
  final RxBool isLoadingTask = false.obs;
  final RxInt selectedTab = 0.obs;

  final RxList<TaskMember> members = <TaskMember>[].obs;
  final RxList<TaskComment> comments = <TaskComment>[].obs;
  final RxList<TaskProgress> progresses = <TaskProgress>[].obs;

  final RxBool membersLoading = true.obs;
  final RxBool commentsLoading = true.obs;
  final RxBool progressesLoading = true.obs;

  final TextEditingController commentTextController = TextEditingController();
  final RxBool isSendingComment = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTabData();
  }

  Future<void> loadFresh(Future<TaskItem?> Function(String id) fetchDetail) async {
    isLoadingTask.value = true;
    try {
      final fresh = await fetchDetail(task.value.id);
      if (fresh != null) task.value = fresh;
    } finally {
      isLoadingTask.value = false;
    }
  }

  Future<void> _loadTabData() async {
    final repo = _repo;
    if (repo == null) {
      membersLoading.value = false;
      commentsLoading.value = false;
      progressesLoading.value = false;
      return;
    }

    final taskId = task.value.id;
    final results = await Future.wait([
      repo.fetchTaskMembers(taskId).catchError((_) => <TaskMember>[]),
      repo.fetchTaskComments(taskId).catchError((_) => <TaskComment>[]),
      repo.fetchTaskProgresses(taskId).catchError((_) => <TaskProgress>[]),
    ]);

    members.assignAll(results[0] as List<TaskMember>);
    membersLoading.value = false;

    comments.assignAll(results[1] as List<TaskComment>);
    commentsLoading.value = false;

    progresses.assignAll(results[2] as List<TaskProgress>);
    progressesLoading.value = false;
  }

  void selectTab(int index) => selectedTab.value = index;

  Future<void> submitComment({String? parentCommentId}) async {
    final repo = _repo;
    if (repo == null) return;
    final content = commentTextController.text.trim();
    if (content.isEmpty) return;

    isSendingComment.value = true;
    try {
      await repo.createTaskComment(
        task.value.id,
        content: content,
        parentCommentId: parentCommentId,
      );
      commentTextController.clear();
      // Refresh comments list
      commentsLoading.value = true;
      final fresh = await repo.fetchTaskComments(task.value.id).catchError((_) => <TaskComment>[]);
      comments.assignAll(fresh);
      commentsLoading.value = false;
    } finally {
      isSendingComment.value = false;
    }
  }

  @override
  void onClose() {
    commentTextController.dispose();
    super.onClose();
  }
}
