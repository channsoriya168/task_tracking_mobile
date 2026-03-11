import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_tracking_mobile/app/utils/constants.dart';
import 'package:task_tracking_mobile/features/auth/presentation/controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _auth.login(_phoneCtrl.text, _passwordCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kBgDark : kBgLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: kPagePaddingWithBottom,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _Logo(),
                  const SizedBox(height: 28),
                  _Headline(isDark: isDark),
                  const SizedBox(height: 36),
                  _PhoneField(controller: _phoneCtrl, isDark: isDark),
                  const SizedBox(height: 16),
                  _PasswordField(
                    controller: _passwordCtrl,
                    isDark: isDark,
                    obscure: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final msg = _auth.errorMessage.value;
                    if (msg.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _ErrorBanner(message: msg),
                    );
                  }),
                  const SizedBox(height: 28),
                  Obx(
                    () => _LoginButton(
                      isLoading: _auth.isLoading.value,
                      onPressed: _submit,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo ──────────────────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: kPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.task_alt_rounded, color: kPrimary, size: 30),
    );
  }
}

// ── Headline ──────────────────────────────────────────────────────────────────
class _Headline extends StatelessWidget {
  const _Headline({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : kTextDark,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your phone number to continue',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white54 : kTextMuted,
          ),
        ),
      ],
    );
  }
}

// ── Phone Field ───────────────────────────────────────────────────────────────
class _PhoneField extends StatelessWidget {
  const _PhoneField({required this.controller, required this.isDark});
  final TextEditingController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _FormField(
      label: 'Phone Number',
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        style: TextStyle(
          color: isDark ? Colors.white : kTextDark,
          fontSize: 15,
        ),
        decoration: _inputDecoration(
          hint: '0884311016',
          icon: Icons.phone_outlined,
          isDark: isDark,
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Phone number is required';
          final digits = v.trim().replaceAll(RegExp(r'\D'), '');
          if (digits.length < 9 || digits.length > 12) {
            return 'Enter a valid phone number';
          }
          return null;
        },
      ),
    );
  }
}

// ── Password Field ────────────────────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.isDark,
    required this.obscure,
    required this.onToggle,
  });
  final TextEditingController controller;
  final bool isDark;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return _FormField(
      label: 'Password',
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        textInputAction: TextInputAction.done,
        style: TextStyle(
          color: isDark ? Colors.white : kTextDark,
          fontSize: 15,
        ),
        decoration: _inputDecoration(
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          isDark: isDark,
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 20,
              color: kTextMuted,
            ),
            onPressed: onToggle,
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Password is required';
          if (v.length < 6) return 'At least 6 characters required';
          return null;
        },
      ),
    );
  }
}

// ── Error Banner ──────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kHighPriority.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kHighPriority.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: kHighPriority, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: kHighPriority,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Login Button ──────────────────────────────────────────────────────────────
class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          disabledBackgroundColor: kPrimary.withValues(alpha: 0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
            : const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[400] : kTextMuted,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

InputDecoration _inputDecoration({
  required String hint,
  required IconData icon,
  required bool isDark,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: isDark ? Colors.grey[600] : Colors.grey[400],
      fontSize: 14,
    ),
    prefixIcon: Icon(icon, size: 20, color: kTextMuted),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: isDark ? kSurfaceDark : const Color(0xFFF7F7FB),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPrimary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kHighPriority),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kHighPriority, width: 1.5),
    ),
  );
}
