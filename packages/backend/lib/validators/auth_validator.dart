import 'package:backend/helpers/response_helper.dart';
import 'package:backend/validators/validation_result.dart';

class AuthValidator {
  static ValidationResult validateAuthCode({required String? code}) {
    if (code == null || code.trim().isEmpty) {
      return ValidationResult.invalid(
        errorMessage: 'Missing authorization code',
        errorCode: ErrorCode.validationError,
      );
    }

    return ValidationResult.valid();
  }

  static ValidationResult validateGameCode({required String? code}) {
    if (code == null || code.trim().isEmpty) {
      return ValidationResult.invalid(
        errorMessage: 'Game code is required',
        errorCode: ErrorCode.validationError,
      );
    }

    if (code.length != 6) {
      return ValidationResult.invalid(
        errorMessage: 'Game code must be 6 characters',
        errorCode: ErrorCode.validationError,
      );
    }

    return ValidationResult.valid();
  }
}
