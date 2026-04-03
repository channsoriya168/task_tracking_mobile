import 'package:flutter/material.dart';
import 'package:task_tracking_mobile/features/core/presentation/widgets/text_field_widget.dart';

/// A self-contained password field with a built-in visibility toggle.
///
/// Manages its own obscure state internally so callers only need to pass
/// [controller], [label], [hint], [isDark], and optionally [errorText].
/// Wrap with [Obx] only when [errorText] is reactive.
///
/// Example – inside an Obx for reactive errors:
/// ```dart
/// Obx(() => PasswordInputWidget(
///   controller: ctrl.passwordCtrl,
///   label: 'Password',
///   hint: 'Enter a strong password',
///   isDark: isDark,
///   isRequired: true,
///   errorText: ctrl.fieldErrors['password'],
/// ))
/// ```
class PasswordInputWidget extends StatefulWidget {
  const PasswordInputWidget({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    this.isRequired = false,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;
  final bool isRequired;
  final String? errorText;

  @override
  State<PasswordInputWidget> createState() => _PasswordInputWidgetState();
}

class _PasswordInputWidgetState extends State<PasswordInputWidget> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFieldWidget(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      isDark: widget.isDark,
      isRequired: widget.isRequired,
      obscureText: _obscure,
      prefixIcon: Icons.lock_outline_rounded,
      suffixIcon: IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 18,
          color: Colors.grey[500],
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      ),
      errorText: widget.errorText,
    );
  }
}
