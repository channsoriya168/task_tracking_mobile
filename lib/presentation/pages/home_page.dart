import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/presentation/controllers/theme_controller.dart';
import 'package:task_tracking_mobile/presentation/widgets/circular_icon_button.dart';
import 'package:task_tracking_mobile/presentation/widgets/list_task_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              actions: [
                //button notification
                CircularIconButton(
                  icon: Icons.notifications,
                  isDark: isDark,
                  onTap: () {},
                ),
                Padding(
                  padding: kPagePaddingHorizontal,
                  child: CircularIconButton(
                    isDark: isDark,
                    icon: isDark ? Icons.light_mode : Icons.dark_mode,
                    onTap: () => themeCtrl.toggle(),
                  ),
                ),
              ],
            ),

            //main have grid
            SliverPadding(
              padding: kPagePadding,
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                    decoration: BoxDecoration(
                      color: isDark ? kCardDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(isDark ? 77 : 21),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  childCount: 4,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
              ),
            ),
            // ── Tasks List ───────────────────────────────────────
            SliverPadding(
              padding: kPageSectionLargePadding,
              sliver: SliverToBoxAdapter(
                child: Text(
                  'All Tasks',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTaskWidget(isDark: isDark),
          ],
        ),
      ),
    );
  }
}
