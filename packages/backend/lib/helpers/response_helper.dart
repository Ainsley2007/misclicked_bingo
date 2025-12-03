import 'dart:io';
import 'package:dart_frog/dart_frog.dart';

enum ErrorCode {
  unauthorized('UNAUTHORIZED'),
  notFound('NOT_FOUND'),
  validationError('VALIDATION_ERROR'),
  forbidden('FORBIDDEN'),
  gameNotStarted('GAME_NOT_STARTED'),
  gameEnded('GAME_ENDED'),
  teamFull('TEAM_FULL'),
  alreadyInTeam('ALREADY_IN_TEAM'),
  alreadyInGame('ALREADY_IN_GAME'),
  notInTeam('NOT_IN_TEAM'),
  notTeamCaptain('NOT_TEAM_CAPTAIN'),
  invalidCredentials('INVALID_CREDENTIALS'),
  resourceExists('RESOURCE_EXISTS'),
  internalError('INTERNAL_ERROR');

  const ErrorCode(this.code);
  final String code;
}

class ResponseHelper {
  static Response success({
    required dynamic data,
    int statusCode = HttpStatus.ok,
  }) {
    return Response.json(
      statusCode: statusCode,
      body: {
        'success': true,
        'data': data,
      },
    );
  }

  static Response created({required dynamic data}) {
    return success(data: data, statusCode: HttpStatus.created);
  }

  static Response noContent() {
    return Response(statusCode: HttpStatus.noContent);
  }

  static Response error({
    required String message,
    required ErrorCode code,
    int? statusCode,
    Map<String, dynamic>? details,
  }) {
    final status = statusCode ?? _getStatusFromErrorCode(code);

    return Response.json(
      statusCode: status,
      body: {
        'error': message,
        'code': code.code,
        if (details != null) 'details': details,
      },
    );
  }

  static Response unauthorized({
    String? message,
    Map<String, dynamic>? details,
  }) {
    return error(
      message: message ?? 'Unauthorized',
      code: ErrorCode.unauthorized,
      statusCode: HttpStatus.unauthorized,
      details: details,
    );
  }

  static Response notFound({String? message, Map<String, dynamic>? details}) {
    return error(
      message: message ?? 'Resource not found',
      code: ErrorCode.notFound,
      statusCode: HttpStatus.notFound,
      details: details,
    );
  }

  static Response forbidden({String? message, Map<String, dynamic>? details}) {
    return error(
      message: message ?? 'Forbidden',
      code: ErrorCode.forbidden,
      statusCode: HttpStatus.forbidden,
      details: details,
    );
  }

  static Response validationError({
    String? message,
    Map<String, dynamic>? details,
  }) {
    return error(
      message: message ?? 'Validation failed',
      code: ErrorCode.validationError,
      statusCode: HttpStatus.badRequest,
      details: details,
    );
  }

  static Response internalError({
    String? message,
    Map<String, dynamic>? details,
  }) {
    return error(
      message: message ?? 'Internal server error',
      code: ErrorCode.internalError,
      statusCode: HttpStatus.internalServerError,
      details: details,
    );
  }

  static Response methodNotAllowed() {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  static int _getStatusFromErrorCode(ErrorCode code) {
    return switch (code) {
      ErrorCode.unauthorized => HttpStatus.unauthorized,
      ErrorCode.notFound => HttpStatus.notFound,
      ErrorCode.forbidden => HttpStatus.forbidden,
      ErrorCode.validationError => HttpStatus.badRequest,
      ErrorCode.gameNotStarted => HttpStatus.forbidden,
      ErrorCode.gameEnded => HttpStatus.forbidden,
      ErrorCode.teamFull => HttpStatus.badRequest,
      ErrorCode.alreadyInTeam => HttpStatus.badRequest,
      ErrorCode.alreadyInGame => HttpStatus.badRequest,
      ErrorCode.notInTeam => HttpStatus.badRequest,
      ErrorCode.notTeamCaptain => HttpStatus.forbidden,
      ErrorCode.invalidCredentials => HttpStatus.unauthorized,
      ErrorCode.resourceExists => HttpStatus.conflict,
      ErrorCode.internalError => HttpStatus.internalServerError,
    };
  }
}
