import 'dart:developer' as developer;
import 'package:frontend/core/error/api_exception.dart';

mixin BlocErrorHandlerMixin {
  Future<void> execute({
    required Future<void> Function() action,
    void Function()? onSuccess,
    required void Function(String message) onError,
    required String context,
    Map<String, String>? errorMessages,
    String? defaultMessage,
  }) async {
    try {
      await action();
      onSuccess?.call();
    } catch (e, stackTrace) {
      final message = _parseError(e, context: context, stackTrace: stackTrace, errorMessages: errorMessages, defaultMessage: defaultMessage);
      onError(message);
    }
  }

  Future<T?> executeWithResult<T>({
    required Future<T> Function() action,
    required void Function(T result) onSuccess,
    required void Function(String message) onError,
    required String context,
    Map<String, String>? errorMessages,
    String? defaultMessage,
  }) async {
    try {
      final result = await action();
      onSuccess(result);
      return result;
    } catch (e, stackTrace) {
      final message = _parseError(e, context: context, stackTrace: stackTrace, errorMessages: errorMessages, defaultMessage: defaultMessage);
      onError(message);
      return null;
    }
  }

  String _parseError(Object error, {required String context, StackTrace? stackTrace, Map<String, String>? errorMessages, String? defaultMessage}) {
    if (error is ApiException) {
      developer.log('${error.code}: ${error.message}', name: context, level: 1000);

      if (errorMessages != null && errorMessages.containsKey(error.code)) {
        return errorMessages[error.code]!;
      }

      return error.message;
    }

    developer.log('Unexpected error', name: context, level: 1000, error: error, stackTrace: stackTrace);

    return defaultMessage ?? 'An unexpected error occurred';
  }

  static const gameErrors = {
    'GAME_NOT_STARTED': 'Game has not started yet',
    'GAME_ENDED': 'Game has already ended',
    'NOT_IN_TEAM': 'You must be in a team',
    'NOT_FOUND': 'Game not found',
  };

  static const teamErrors = {
    'TEAM_FULL': 'Team is full',
    'ALREADY_IN_TEAM': 'User is already in a team',
    'NOT_IN_TEAM': 'You must be in a team',
    'NOT_TEAM_CAPTAIN': 'Only team captain can perform this action',
    'NOT_FOUND': 'Team not found',
  };

  static const authErrors = {
    'UNAUTHORIZED': 'Authentication required',
    'FORBIDDEN': 'You do not have permission to perform this action',
    'INVALID_CREDENTIALS': 'Invalid credentials',
  };

  static const validationErrors = {'VALIDATION_ERROR': 'Please check your input and try again', 'RESOURCE_EXISTS': 'This resource already exists'};
}
