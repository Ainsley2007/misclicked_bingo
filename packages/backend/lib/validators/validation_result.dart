import 'package:backend/helpers/response_helper.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final ErrorCode? errorCode;
  final Map<String, dynamic>? details;

  ValidationResult.valid()
    : isValid = true,
      errorMessage = null,
      errorCode = null,
      details = null;

  ValidationResult.invalid({
    required this.errorMessage,
    required this.errorCode,
    this.details,
  }) : isValid = false;
}
