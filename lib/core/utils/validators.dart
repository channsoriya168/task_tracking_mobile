/// App-wide form validators and phone utilities.
class Validators {
  Validators._();

  // ── Phone ────────────────────────────────────────────────────────────────

  /// Validates a Cambodian phone number entered by the user.
  /// Accepts formats: `0884311016`, `884311016`, `+855884311016`.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }
    final raw = value.trim();
    // Strip leading + or 0 prefix then check digit count
    final stripped = raw.startsWith('+855')
        ? raw.substring(4)
        : raw.startsWith('0')
        ? raw.substring(1)
        : raw;

    if (!RegExp(r'^\d{8,9}$').hasMatch(stripped)) {
      return 'Enter a valid Cambodian phone number.';
    }
    return null;
  }

  /// Converts a user-entered phone to E.164 format (+855…).
  /// `0884311016` → `+855884311016`
  /// Numbers already starting with `+` are returned unchanged.
  static String toE164(String phone) {
    final digits = phone.trim();
    if (digits.startsWith('+')) return digits;
    if (digits.startsWith('0')) return '+855${digits.substring(1)}';
    return '+855$digits';
  }

  // ── Generic ──────────────────────────────────────────────────────────────

  /// Non-empty check with an optional custom label.
  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }
}
