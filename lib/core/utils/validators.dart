/// SecureMail — Form Validators
/// Usage: validator: Validators.email
class Validators {
  Validators._();

  // ── Email ────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ── Password ─────────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  // ── Confirm Password ──────────────────────────────────────
  static String? Function(String?) confirmPassword(String original) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != original) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  // ── Required Field ────────────────────────────────────────
  static String? Function(String?) required(String fieldName) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return '$fieldName is required';
      }
      return null;
    };
  }

  // ── Email Subject ─────────────────────────────────────────
  static String? subject(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Subject is required';
    }
    if (value.trim().length > 255) {
      return 'Subject is too long';
    }
    return null;
  }

  // ── Email Recipients ──────────────────────────────────────
  static String? recipients(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'At least one recipient is required';
    }
    final emails = value.split(',').map((e) => e.trim()).toList();
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    for (final email in emails) {
      if (!emailRegex.hasMatch(email)) {
        return '"$email" is not a valid email';
      }
    }
    return null;
  }

  // ── Name ──────────────────────────────────────────────────
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name is too short';
    }
    return null;
  }
}
