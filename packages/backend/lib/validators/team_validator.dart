import 'package:backend/helpers/response_helper.dart';
import 'package:backend/validators/validation_result.dart';

class TeamValidator {
  static ValidationResult validateTeamColor({required String? color}) {
    if (color == null || color.trim().isEmpty) {
      return ValidationResult.invalid(
        errorMessage: 'Team color is required',
        errorCode: ErrorCode.validationError,
      );
    }

    final hexColorPattern = RegExp(r'^#[0-9A-Fa-f]{6}$');
    if (!hexColorPattern.hasMatch(color)) {
      return ValidationResult.invalid(
        errorMessage: 'Color must be a valid hex color (e.g., #FF5733)',
        errorCode: ErrorCode.validationError,
      );
    }

    return ValidationResult.valid();
  }

  static ValidationResult validateTeamName({required String? name}) {
    if (name == null || name.trim().isEmpty) {
      return ValidationResult.invalid(
        errorMessage: 'Team name is required',
        errorCode: ErrorCode.validationError,
      );
    }

    if (name.trim().length > 50) {
      return ValidationResult.invalid(
        errorMessage: 'Team name must be 50 characters or less',
        errorCode: ErrorCode.validationError,
      );
    }

    return ValidationResult.valid();
  }

  static ValidationResult validateTeamSize({
    required int currentSize,
    required int maxSize,
  }) {
    if (currentSize >= maxSize) {
      return ValidationResult.invalid(
        errorMessage: 'Team is full',
        errorCode: ErrorCode.teamFull,
        details: {'currentSize': currentSize, 'maxSize': maxSize},
      );
    }

    return ValidationResult.valid();
  }
}
