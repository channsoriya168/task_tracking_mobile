import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/widgets/confirm_delete_dialog.dart';

Future<bool> confirmDeleteEmployee(BuildContext context, String name) async {
  final result = await showConfirmDeleteDialog(
    context,
    title: 'employee_confirm_delete_title'.tr,
    content: 'employee_confirm_delete_msg'.trParams({'name': name}),
  );
  return result == true;
}
