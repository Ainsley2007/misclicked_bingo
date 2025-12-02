class ApiException implements Exception {
  const ApiException({required this.message, required this.code, this.details, this.statusCode});

  final String message;
  final String code;
  final Map<String, dynamic>? details;
  final int? statusCode;

  bool get isNotFound => code == 'NOT_FOUND';
  bool get isUnauthorized => code == 'UNAUTHORIZED';
  bool get isForbidden => code == 'FORBIDDEN';
  bool get isValidationError => code == 'VALIDATION_ERROR';
  bool get isGameNotStarted => code == 'GAME_NOT_STARTED';
  bool get isGameEnded => code == 'GAME_ENDED';
  bool get isTeamFull => code == 'TEAM_FULL';
  bool get isAlreadyInTeam => code == 'ALREADY_IN_TEAM';
  bool get isNotInTeam => code == 'NOT_IN_TEAM';
  bool get isNotTeamCaptain => code == 'NOT_TEAM_CAPTAIN';

  @override
  String toString() => 'ApiException: [$code] $message';
}
