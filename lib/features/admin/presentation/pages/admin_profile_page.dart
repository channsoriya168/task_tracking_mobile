import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/admin/presentation/widgets/admin_profile_widgets.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: kPagePadding,
              child: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : kTextDark,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: AdminProfileHeader(isDark: isDark)),
SliverToBoxAdapter(child: AdminProfileSettings(isDark: isDark)),
          SliverToBoxAdapter(child: AdminProfileSignOut(onTap: () {})),
        ],
      ),
    );
  }
}
