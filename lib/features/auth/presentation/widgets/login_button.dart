import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          disabledBackgroundColor: kPrimary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'login_sign_in'.tr,
                style: AppTextStyles.buttonLabel(color: Colors.white),
              ),
      ),
    );
  }
}
