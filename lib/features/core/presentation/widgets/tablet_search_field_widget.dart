import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';

class TabletSearchFieldWidget extends StatelessWidget {
  const TabletSearchFieldWidget({
    super.key,
    required this.isDark,
    required this.onChanged,
    this.hintText = 'Search',
  });

  final bool isDark;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 40,
      child: TextField(
        onChanged: onChanged,
        style: AppTextStyles.title(color: isDark ? Colors.white : kPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.title(
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 18,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          filled: true,
          fillColor: isDark ? kCardDark : Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withAlpha(18)
                  : Colors.grey.withAlpha(40),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withAlpha(18)
                  : Colors.grey.withAlpha(40),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: kPrimary),
          ),
        ),
      ),
    );
  }
}
