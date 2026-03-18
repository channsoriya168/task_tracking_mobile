import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class TaskDetailTabLoader extends StatelessWidget {
  const TaskDetailTabLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 80,
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: kPrimary),
        ),
      ),
    );
  }
}
