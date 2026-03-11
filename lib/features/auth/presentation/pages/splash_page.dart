import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Column(
            children: [
              const Spacer(flex: 4),

              // ── Logo ────────────────────────────────────────────
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3FB),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withValues(alpha: 0.18),
                      blurRadius: 48,
                      spreadRadius: 0,
                      offset: const Offset(0, 20),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, st) => Container(
                      color: kPrimary.withValues(alpha: 0.08),
                      child: const Icon(
                        Icons.business_rounded,
                        size: 64,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1.0, 1.0),
                    duration: 700.ms,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 32),

              // ── Company name ─────────────────────────────────────
              Text(
                'IT Solution',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                  letterSpacing: -1.0,
                  height: 1.1,
                ),
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(
                    begin: 0.4,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 4),

              // ── Sub-name ─────────────────────────────────────────
              Text(
                'Digital',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: kPrimary,
                  letterSpacing: -1.0,
                  height: 1.1,
                ),
              )
                  .animate(delay: 420.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(
                    begin: 0.4,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: 12),

              // ── Tagline ──────────────────────────────────────────
              Text(
                'Manage smarter. Deliver faster.',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: kTextMuted,
                  letterSpacing: 0.2,
                ),
              )
                  .animate(delay: 560.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic,
                  ),

              const Spacer(flex: 5),

              // ── Progress section ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 52),
                child: Column(
                  children: [
                    SizedBox(
                      height: 5,
                      child: Stack(
                        children: [
                          // Track
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEEF5),
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          // Animated fill — driven by controller
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

                    const SizedBox(height: 14),

                    Text(
                      'Loading resources...',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: kTextMuted.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              )
                  .animate(delay: 700.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    );
  }
}
