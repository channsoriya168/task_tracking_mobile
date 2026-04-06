import 'package:get/get.dart';
import 'package:task_tracking_mobile/core/utils/validators.dart';

/// Validates employee form inputs and returns a map of field-key → error message.
/// An empty map means all inputs are valid.
class EmployeeValidator {
  EmployeeValidator._();

  static Map<String, String> validateCreate({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required DateTime? dob,
    required String? groupId,
    required String? genderId,
  }) {
    final errors = <String, String>{};

    final nameErr = Validators.required(name, label: 'Full name');
    if (nameErr != null) errors['fullName'] = nameErr;

    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      errors['email'] = 'Enter a valid email address.';
    }

    final phoneErr = Validators.phone(phone);
    if (phoneErr != null) errors['phone'] = phoneErr;

    final pwErr = Validators.strongPassword(password);
    if (pwErr != null) errors['password'] = pwErr;

    if (confirmPassword.isEmpty) {
      errors['confirmPassword'] = 'Please confirm your password.';
    } else if (password != confirmPassword) {
      errors['confirmPassword'] = 'Passwords do not match.';
    }

    if (dob == null) errors['dob'] = 'Date of birth is required.';
    if (genderId == null) errors['gender'] = 'Please select a gender.';
    if (groupId == null) errors['taskGroup'] = 'Please select a task group.';

    return errors;
  }

  static Map<String, String> validateEdit({
    required String name,
    required String email,
    required String phone,
    required DateTime? dob,
    required String? groupId,
    required String? genderId,
    String password = '',
    String confirmPassword = '',
  }) {
    final errors = <String, String>{};

    final nameErr = Validators.required(name, label: 'Full name');
    if (nameErr != null) errors['fullName'] = nameErr;

    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      errors['email'] = 'Enter a valid email address.';
    }

    if (phone.isNotEmpty) {
      final phoneErr = Validators.phone(phone);
      if (phoneErr != null) errors['phone'] = phoneErr;
    }

    if (password.isNotEmpty) {
      final pwErr = Validators.strongPassword(password);
      if (pwErr != null) errors['password'] = pwErr;
      if (confirmPassword.isEmpty) {
        errors['confirmPassword'] = 'Please confirm your password.';
      } else if (password != confirmPassword) {
        errors['confirmPassword'] = 'Passwords do not match.';
      }
    }

    if (dob == null) errors['dob'] = 'Date of birth is required.';
    if (genderId == null) errors['gender'] = 'Please select a gender.';
    if (groupId == null) errors['taskGroup'] = 'Please select a task group.';

    return errors;
  }
}
