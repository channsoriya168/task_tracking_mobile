import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/core/utils/responsive.dart';
import 'package:task_tracking_mobile/features/auth/presentation/pages/login_mobile_page.dart';
import 'package:task_tracking_mobile/features/auth/presentation/pages/login_tablet_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: Responsive.isMobile(context)
          ? LoginMobilePage(isDark: isDark)
          : LoginTabletPage(isDark: isDark),
    );
  }
}
