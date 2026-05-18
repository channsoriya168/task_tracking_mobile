import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';

/// Shows a centred no-internet dialog that auto-redirects after 3 seconds.
///
/// [redirectCount] — routes popped on timeout:
/// - `1` close dialog only
/// - `2` close dialog + current page (default)
Future<void> showNoInternetDialog({
  required bool isDark,
  int redirectCount = 2,
}) {
  // Timer lives here so the widget stays stateless.
  // Safe because barrierDismissible is false — the only way the dialog
  // closes before 3 s is if the route is already gone, which is harmless.
  Timer(const Duration(seconds: 3), () => Get.close(redirectCount));

  return Get.dialog<void>(
    NoInternetDialog(isDark: isDark),
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.55),
  );
}

class NoInternetDialog extends StatelessWidget {
  final bool isDark;

  const NoInternetDialog({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? kCardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Red accent header ────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF4757), Color(0xFFFF6B6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // ── Message body ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              child: Column(
                children: [
                  Text(
                    'no_internet_title'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: kLs(-0.3),
                      color: isDark ? Colors.white : kTextDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'no_internet_subtitle'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? Colors.grey[400] : kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
