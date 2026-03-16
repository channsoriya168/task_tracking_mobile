import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/app/utils/responsive.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:task_tracking_mobile/features/core/data/models/nav_item.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/navigation/bottom_nav_bar_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/navigation/navigation_rail_widget.dart';
import 'package:task_tracking_mobile/features/core/presentation/controllers/navigation_controller.dart';

class ResponsiveScaffold extends StatelessWidget {
  final List<NavItem> navItems;

  ResponsiveScaffold({super.key, required this.navItems});

  final NavigationController _navCtrl = Get.find();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(0, 245, 16, 16),
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    final isMobile = Responsive.isMobile(context);

    final bottomTabs = navItems.map((item) {
      if (item.label == 'Profile') {
        return GButton(
          icon: item.icon,
          text: item.label,
          leading: _ProfileAvatarIcon(),
        );
      }
      return GButton(icon: item.icon, text: item.label);
    }).toList();

    final railItems = navItems
        .map((item) => NavRailItem(icon: item.icon, label: item.label))
        .toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      // Clamp index in case navItems count changed between roles
      final index = _navCtrl.selectedIndex.value.clamp(0, navItems.length - 1);
      return Scaffold(
        backgroundColor: isDark ? kBgDark : kBgLight,
        body: SafeArea(
          bottom: false,
          child: Row(
            children: [
              if (!isMobile) NavigationRailWidget(items: railItems),
              Expanded(child: navItems[index].page),
            ],
          ),
        ),
        bottomNavigationBar: isMobile
            ? BottomNavBarWidget(tabs: bottomTabs)
            : null,
      );
    });
  }
}

class _ProfileAvatarIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authCtrl = Get.find<AuthController>();
      final profile = authCtrl.profile.value;
      final auth = authCtrl.currentAuth.value;
      final name = profile?.fullName ?? auth?.fullName ?? '';
      final imageUrl = profile?.profileImageUrl;
      final letter = name.isNotEmpty ? name[0].toUpperCase() : '?';

      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kPrimary.withAlpha(30),
          border: Border.all(color: kPrimary.withAlpha(80), width: 1.5),
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: kPrimary,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    letter,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: kPrimary,
                    ),
                  ),
                ),
        ),
      );
    });
  }
}
