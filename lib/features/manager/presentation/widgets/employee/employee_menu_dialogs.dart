import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

Future<bool> confirmDeleteEmployee(String name) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Delete Employee'),
      content: Text('Remove "$name" from the team?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: kHighPriority),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result == true;
}

Future<bool> confirmResetQr() async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Reset QR Code'),
      content: const Text(
        'This will invalidate the current QR code and generate a new one. '
        'The employee must use the new QR code to log in.',
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: kMediumPriority),
          child: const Text('Reset'),
        ),
      ],
    ),
  );
  return result == true;
}
