import 'package:flutter/foundation.dart';
import 'package:shared_models/shared_models.dart';

@immutable
sealed class ManageTeamsState {
  const ManageTeamsState();

  String? get teamId => null;
  String? get gameId => null;
  String? get teamName => null;
  String? get teamColor => null;
  int? get teamSize => null;
  List<AppUser> get teamMembers => const [];
  List<AppUser> get availableUsers => const [];
  List<AppUser> get unavailableUsers => const [];
}

@immutable
final class ManageTeamsInitial extends ManageTeamsState {
  const ManageTeamsInitial();
}

@immutable
final class ManageTeamsLoading extends ManageTeamsState {
  const ManageTeamsLoading({String? teamId, String? gameId})
    : _teamId = teamId,
      _gameId = gameId;

  final String? _teamId;
  final String? _gameId;

  @override
  String? get teamId => _teamId;
  @override
  String? get gameId => _gameId;
}

@immutable
final class ManageTeamsLoaded extends ManageTeamsState {
  const ManageTeamsLoaded({
    required String teamId,
    required String gameId,
    required String teamName,
    required String teamColor,
    required int teamSize,
    required List<AppUser> teamMembers,
    required List<AppUser> availableUsers,
    List<AppUser>? unavailableUsers,
    this.message,
  }) : _teamId = teamId,
       _gameId = gameId,
       _teamName = teamName,
       _teamColor = teamColor,
       _teamSize = teamSize,
       _teamMembers = teamMembers,
       _availableUsers = availableUsers,
       _unavailableUsers = unavailableUsers ?? const [];

  final String _teamId;
  final String _gameId;
  final String _teamName;
  final String _teamColor;
  final int _teamSize;
  final List<AppUser> _teamMembers;
  final List<AppUser> _availableUsers;
  final List<AppUser> _unavailableUsers;
  final String? message;

  @override
  String get teamId => _teamId;
  @override
  String get gameId => _gameId;
  @override
  String get teamName => _teamName;
  @override
  String get teamColor => _teamColor;
  @override
  int get teamSize => _teamSize;
  @override
  List<AppUser> get teamMembers => _teamMembers;
  @override
  List<AppUser> get availableUsers => _availableUsers;
  @override
  List<AppUser> get unavailableUsers => _unavailableUsers;
}

@immutable
final class ManageTeamsError extends ManageTeamsState {
  const ManageTeamsError(this.message, {String? gameId}) : _gameId = gameId;

  final String message;
  final String? _gameId;

  @override
  String? get gameId => _gameId;
}
