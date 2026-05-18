import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

class PhoneFieldWidget extends StatelessWidget {
  const PhoneFieldWidget({
    super.key,
    required this.controller,
    required this.isDark,
    this.errorText,
    this.isRequired = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final bool isDark;
  final String? errorText;
  final bool isRequired;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextStyles.formLabel(
              color: isDark ? Colors.white : kTextDark,
            ),
            children: [
              TextSpan(text: 'phone_number'.tr),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntlPhoneField(
          controller: controller,
          initialCountryCode: 'KH',
          disableLengthCheck: true,
          showDropdownIcon: false,
          flagsButtonPadding: const EdgeInsets.only(left: 14, right: 8),
          style: AppTextStyles.formLabel(
            color: isDark ? Colors.white : kTextDark,
          ),
          dropdownTextStyle: AppTextStyles.formLabel(
            color: isDark ? Colors.white : kTextDark,
          ),
          decoration: InputDecoration(
            hintText: '97 447 9834',
            hintStyle: AppTextStyles.formLabel(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            errorText: errorText,
            filled: true,
            fillColor: isDark ? kSurfaceDark : kBgLight,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kPrimary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          onChanged: (phone) {
            if (onChanged != null) onChanged!(phone.completeNumber);
          },
        ),
      ],
    );
  }
}
