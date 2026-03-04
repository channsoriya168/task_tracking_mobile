import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/presentation/pages/home_page.dart';
import 'package:task_tracking_mobile/presentation/pages/profile_page.dart';
import 'package:task_tracking_mobile/presentation/pages/tasks_page.dart';
import 'package:task_tracking_mobile/presentation/widgets/responsive_scaffold.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const HomePage(),
      const TasksPage(),
      const ProfilePage(),
    ];
    return ResponsiveScaffold(pages: pages);
  }
}
