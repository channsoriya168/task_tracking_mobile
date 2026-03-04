import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/presentation/controllers/task_controller.dart';
import 'package:task_tracking_mobile/presentation/pages/dashboard_page.dart';
import 'package:task_tracking_mobile/presentation/pages/profile_page.dart';
import 'package:task_tracking_mobile/presentation/pages/stats_page.dart';
import 'package:task_tracking_mobile/presentation/pages/tasks_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _pages = [
    DashboardPage(),
    TasksPage(),
    StatsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => Scaffold(
        backgroundColor: isDark ? kBgDark : kBgLight,
        body: IndexedStack(
          index: ctrl.navIndex.value,
          children: _pages,
        ),
        floatingActionButton: ctrl.navIndex.value == 1
            ? FloatingActionButton(
                onPressed: () => TasksPage.showTaskSheet(context, ctrl, null),
                backgroundColor: kTextDark,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                child: const Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: _BottomNav(ctrl: ctrl, isDark: isDark),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final TaskController ctrl;
  final bool isDark;

  const _BottomNav({required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white12 : Colors.grey.shade200,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _icon(Icons.grid_view_rounded, 0),
            _pill(Icons.task_alt_rounded, 'Task', 1),
            _icon(Icons.bar_chart_rounded, 2),
            _avatar(3),
          ],
        ),
      ),
    );
  }

  Widget _icon(IconData icon, int index) {
    final active = ctrl.navIndex.value == index;
    return GestureDetector(
      onTap: () => ctrl.navIndex.value = index,
      child: Icon(
        icon,
        size: 26,
        color: active
            ? kPrimary
            : (isDark ? Colors.white38 : Colors.grey.shade400),
      ),
    );
  }

  Widget _pill(IconData icon, String label, int index) {
    final active = ctrl.navIndex.value == index;
    return GestureDetector(
      onTap: () => ctrl.navIndex.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active ? kTextDark : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: active
                  ? Colors.white
                  : (isDark ? Colors.white38 : Colors.grey.shade400),
            ),
            if (active) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _avatar(int index) {
    final active = ctrl.navIndex.value == index;
    return GestureDetector(
      onTap: () => ctrl.navIndex.value = index,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kPrimary, Color(0xFF9B8FFF)],
          ),
          shape: BoxShape.circle,
          border: active
              ? Border.all(color: kPrimary, width: 2.5)
              : null,
          boxShadow: active
              ? [BoxShadow(color: kPrimary.withOpacity(0.4), blurRadius: 8)]
              : null,
        ),
        child: const Center(
          child: Text(
            'A',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
