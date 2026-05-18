import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/core/constants/constants.dart';
import 'package:task_tracking_mobile/core/widgets/language_switcher_widget.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_bg_circles.dart';
import 'package:task_tracking_mobile/features/auth/presentation/widgets/login_form_card.dart';

class LoginMobilePage extends StatelessWidget {
  const LoginMobilePage({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LoginBgCircles(isDark: isDark),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [LanguageSwitcherPill(isDark: isDark)],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: kPagePaddingWithBottom,
                    child: LoginFormCard(isDark: isDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
