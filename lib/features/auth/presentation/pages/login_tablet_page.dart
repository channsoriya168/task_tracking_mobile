import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/utils/constants.dart';
import 'package:task_tracking_mobile/core/widgets/language_switcher_widget.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_brand_panel.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_form_card.dart';

class LoginTabletPage extends StatelessWidget {
  const LoginTabletPage({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Left: branding ──────────────────────────────────
        Expanded(flex: 5, child: LoginBrandPanel(isDark: isDark)),
        // ── Right: form ─────────────────────────────────────
        Expanded(
          flex: 6,
          child: Container(
            color: isDark ? kBgDark : kSurfaceLight,
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [LanguageSwitcherPill(isDark: isDark)],
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 440,
                                ),
                                child: LoginFormCard(isDark: isDark),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
