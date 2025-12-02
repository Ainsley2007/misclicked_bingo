import 'package:backend/helpers/response_helper.dart';
import 'package:backend/validators/validation_result.dart';

class GameValidator {
  static ValidationResult validateCreateGame({
    required String? name,
    required int teamSize,
    required int boardSize,
    required String gameMode,
    DateTime? startTime,
    DateTime? endTime,
    List<dynamic>? tiles,
  }) {
    if (name == null || name.trim().isEmpty) {
      return ValidationResult.invalid(
        errorMessage: 'Game name is required',
        errorCode: ErrorCode.validationError,
      );
    }

    if (teamSize < 1 || teamSize > 50) {
      return ValidationResult.invalid(
        errorMessage: 'Team size must be between 1 and 50',
        errorCode: ErrorCode.validationError,
      );
    }

    if (![2, 3, 4, 5].contains(boardSize)) {
      return ValidationResult.invalid(
        errorMessage: 'Board size must be 2, 3, 4, or 5',
        errorCode: ErrorCode.validationError,
      );
    }

    if (!['blackout', 'points'].contains(gameMode)) {
      return ValidationResult.invalid(
        errorMessage: 'Game mode must be "blackout" or "points"',
        errorCode: ErrorCode.validationError,
      );
    }

    if (startTime != null && endTime != null && endTime.isBefore(startTime)) {
      return ValidationResult.invalid(
        errorMessage: 'End time must be after start time',
        errorCode: ErrorCode.validationError,
      );
    }

    final requiredTiles = boardSize * boardSize;
    if (tiles != null && tiles.isNotEmpty && tiles.length != requiredTiles) {
      return ValidationResult.invalid(
        errorMessage:
            'Must have exactly $requiredTiles tiles for ${boardSize}x$boardSize board',
        errorCode: ErrorCode.validationError,
      );
    }

    if (gameMode == 'points' && tiles != null && tiles.isNotEmpty) {
      for (var i = 0; i < tiles.length; i++) {
        final t = tiles[i] as Map<String, dynamic>;
        final tilePoints = (t['points'] as num?)?.toInt() ?? 0;
        if (tilePoints <= 0) {
          return ValidationResult.invalid(
            errorMessage: 'Tile ${i + 1} must have points > 0 for points mode',
            errorCode: ErrorCode.validationError,
          );
        }
      }
    }

    return ValidationResult.valid();
  }

  static ValidationResult validateUpdateGame({String? name}) {
    if (name != null && name.trim().isEmpty) {
      return ValidationResult.invalid(
        errorMessage: 'Game name cannot be empty',
        errorCode: ErrorCode.validationError,
      );
    }

    return ValidationResult.valid();
  }

  static ValidationResult validateGameTiming({
    required DateTime now,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    if (startTime != null && now.isBefore(startTime)) {
      return ValidationResult.invalid(
        errorMessage: 'Game has not started yet',
        errorCode: ErrorCode.gameNotStarted,
        details: {
          'startTime': startTime.toIso8601String(),
          'serverTimeUtc': now.toIso8601String(),
        },
      );
    }

    if (endTime != null && now.isAfter(endTime)) {
      return ValidationResult.invalid(
        errorMessage: 'Game has ended',
        errorCode: ErrorCode.gameEnded,
        details: {
          'endTime': endTime.toIso8601String(),
          'serverTimeUtc': now.toIso8601String(),
        },
      );
    }

    return ValidationResult.valid();
  }
}
