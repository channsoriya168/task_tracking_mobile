import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/themes/app_text_styles.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final logoSize = isTablet ? 160.0 : 120.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            // ── Decorative circles ─────────────────────────────
            Positioned(
              top: -80,
              right: -60,
              child: _Circle(260, 0.08),
            ),
            Positioned(
              top: 90,
              right: 55,
              child: _Circle(90, 0.12),
            ),
            Positioned(
              top: size.height * 0.28,
              left: -35,
              child: _Circle(130, 0.06),
            ),
            Positioned(
              bottom: -100,
              left: -70,
              child: _Circle(300, 0.07),
            ),
            Positioned(
              bottom: 190,
              left: 30,
              child: _Circle(65, 0.11),
            ),
            Positioned(
              bottom: 80,
              right: 50,
              child: _Circle(45, 0.09),
            ),

            // ── Main content ───────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── Logo ─────────────────────────────────────
                  Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(logoSize * 0.24),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimary.withValues(alpha: 0.18),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(logoSize * 0.24),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.business_rounded,
                          size: logoSize * 0.55,
                          color: kPrimary,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.55, 0.55),
                        end: const Offset(1.0, 1.0),
                        duration: 750.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 32),

                  // ── App name ──────────────────────────────────
                  Text(
                    'Task Tracking',
                    style: AppTextStyles.loginTitle(color: kTextDark),
                  )
                      .animate(delay: 320.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(
                        begin: 0.35,
                        end: 0.0,
                        duration: 500.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: 10),

                  // ── Tagline ───────────────────────────────────
                  Text(
                    'login_subtitle'.tr,
                    style: AppTextStyles.loginSubtitle(color: kTextMuted),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 460.ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(
                        begin: 0.35,
                        end: 0.0,
                        duration: 500.ms,
                        curve: Curves.easeOut,
                      ),

                  const Spacer(flex: 3),

                  // ── Progress bar ──────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 120.0 : 52.0,
                    ),
                    child: SizedBox(
                      height: isTablet ? 5.0 : 4.0,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEEF5),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
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
                  ).animate(delay: 700.ms).fadeIn(duration: 400.ms),

                  SizedBox(height: isTablet ? 72.0 : 52.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle(this.size, this.opacity);
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: kPrimary.withValues(alpha: opacity),
      ),
    );
  }
}
