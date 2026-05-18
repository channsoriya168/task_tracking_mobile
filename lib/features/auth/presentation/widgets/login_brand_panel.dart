import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/app_text_styles.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

class LoginBrandPanel extends StatelessWidget {
  const LoginBrandPanel({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A1535), const Color(0xFF2D2B55)]
              : [const Color(0xFF5A52E8), kPrimary],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: _Circle(220, Colors.white.withValues(alpha: 0.06)),
          ),
          Positioned(
            top: 100,
            right: 70,
            child: _Circle(70, Colors.white.withValues(alpha: 0.09)),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: _Circle(240, Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            bottom: 150,
            left: 45,
            child: _Circle(55, Colors.white.withValues(alpha: 0.11)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.business_rounded,
                          size: 60,
                          color: kPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Task Tracking',
                    style: AppTextStyles.loginTitle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'login_subtitle'.tr,
                    style: AppTextStyles.loginSubtitle(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle(this.size, this.color);
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
