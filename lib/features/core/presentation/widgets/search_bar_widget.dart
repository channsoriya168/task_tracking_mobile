import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    required this.isDark,
    required this.onChanged,
    this.controller,
    this.hintText = 'Search',
  });

  final bool isDark;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPageSectionPadding,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white : kTextDark,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : kTextMuted,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark ? Colors.grey[600] : kTextMuted,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
