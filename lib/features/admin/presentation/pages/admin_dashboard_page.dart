import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/circular_icon_button.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Admin Dashboard'),
            actions: [
              CircularIconButton(
                icon: Icons.settings,
                isDark: Theme.of(context).brightness == Brightness.dark,
                onTap: () {
                  // Handle settings tap
                },
              ),
            ],
          ),
          const SliverFillRemaining(
            child: Center(child: Text('Welcome to the Admin Dashboard')),
          ),
        ],
      ),
    );
  }
}
