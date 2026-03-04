import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class ListTaskWidget extends StatelessWidget {
  const ListTaskWidget({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: kPageSectionPadding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Container(
            height: 80,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? kBgDark : kBgLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white : Colors.black,
                width: 0.5,
              ),
            ),
          ),
          childCount: 5,
        ),
      ),
    );
  }
}
