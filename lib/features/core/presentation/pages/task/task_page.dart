import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/responsive.dart';
import 'package:task_tracking_mobile/features/core/presentation/pages/task/task_mobile_page.dart';
import 'package:task_tracking_mobile/features/core/presentation/pages/task/task_tablet_page.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const TaskMobilePage();
    }
    return const TaskTabletPage();
  }
}
