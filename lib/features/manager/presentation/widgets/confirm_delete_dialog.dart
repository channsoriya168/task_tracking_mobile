import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

Future<bool?> showConfirmDeleteDialog(
  BuildContext context, {
  required String title,
  required String content,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: kHighPriority),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}