import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/responsive.dart';
import 'package:task_tracking_mobile/features/admin/presentation/pages/task/admin_task_mobile.dart';
import 'package:task_tracking_mobile/features/admin/presentation/pages/task/admin_task_tablet_page.dart';

class AdminTaskPage extends StatelessWidget {
  const AdminTaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return const AdminTaskMobile();
    }
    return const AdminTaskTabletPage();
  }
}
