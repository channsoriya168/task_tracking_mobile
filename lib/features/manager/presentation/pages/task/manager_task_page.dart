import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/responsive.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/task/manager_task_mobile_page.dart';
import 'package:task_tracking_mobile/features/manager/presentation/pages/task/manager_task_tablet_page.dart';

class ManagerTaskPage extends StatelessWidget {
  const ManagerTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const ManagerTaskMobilePage();
    }
    return const ManagerTaskTabletPage();
  }
}
