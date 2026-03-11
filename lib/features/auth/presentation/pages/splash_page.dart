import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    final logoSize = isTablet ? 400.0 : 250.0;
    final progressPadding = isTablet ? 120.0 : 52.0;
    final bottomSpacing = isTablet ? 72.0 : 52.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            children: [
              const Spacer(),

              // ── Logo ─────────────────────────────────────────────
              SizedBox(
                width: logoSize,
                child: Image.asset(
                  'assets/images/logo.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, st) => Icon(
                    Icons.business_rounded,
                    size: logoSize * 0.60,
                    color: kPrimary,
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1.0, 1.0),
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                  ),

              const Spacer(),

              // ── Progress bar ──────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: progressPadding),
                child: Column(
                  children: [
                    SizedBox(
                      height: isTablet ? 5.0 : 4.0,
                      child: Stack(
                        children: [
                          // Track
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEEF5),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          // Animated fill
                          Obx(
                            () => AnimatedFractionallySizedBox(
                              duration: 2800.ms,
                              curve: Curves.easeInOut,
                              widthFactor: controller.progress.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF9D8FFF), kPrimary],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 700.ms).fadeIn(duration: 400.ms),

              SizedBox(height: bottomSpacing),
            ],
          ),
        ),
      ),
    );
  }
}
