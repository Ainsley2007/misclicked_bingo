import 'package:backend/helpers/response_helper.dart';
import 'package:backend/validators/validation_result.dart';

class TileValidator {
  static ValidationResult validateTile({
    required String? bossId,
    required bool isAnyUnique,
    List<dynamic>? uniqueItems,
  }) {
    if (bossId == null || bossId.trim().isEmpty) {
      return ValidationResult.invalid(
        errorMessage: 'Boss ID is required for all tiles',
        errorCode: ErrorCode.validationError,
      );
    }

    if (!isAnyUnique && (uniqueItems == null || uniqueItems.isEmpty)) {
      return ValidationResult.invalid(
        errorMessage:
            'At least one unique item is required for each tile (or use "Any Unique" option)',
        errorCode: ErrorCode.validationError,
      );
    }

    if (uniqueItems != null) {
      for (final item in uniqueItems) {
        final itemData = item as Map<String, dynamic>;
        final itemName = itemData['itemName'] as String?;

        if (itemName != null && itemName.trim().isEmpty) {
          return ValidationResult.invalid(
            errorMessage: 'Unique item name cannot be empty',
            errorCode: ErrorCode.validationError,
          );
        }
      }
    }

    return ValidationResult.valid();
  }

  static ValidationResult validateUniqueItems({
    required List<dynamic> uniqueItems,
  }) {
    for (final item in uniqueItems) {
      final itemData = item as Map<String, dynamic>;
      final itemName = itemData['itemName'] as String?;
      final requiredCount = (itemData['requiredCount'] as num?)?.toInt();

      if (itemName == null || itemName.trim().isEmpty) {
        return ValidationResult.invalid(
          errorMessage: 'Item name is required',
          errorCode: ErrorCode.validationError,
        );
      }

      if (requiredCount != null && requiredCount < 1) {
        return ValidationResult.invalid(
          errorMessage: 'Required count must be at least 1',
          errorCode: ErrorCode.validationError,
        );
      }
    }

    return ValidationResult.valid();
  }
}
