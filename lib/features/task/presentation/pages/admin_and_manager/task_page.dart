import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/responsive.dart';
import 'package:task_tracking_mobile/features/task/presentation/pages/admin_and_manager/task_mobile_page.dart';
import 'package:task_tracking_mobile/features/task/presentation/pages/admin_and_manager/task_tablet_page.dart';

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
