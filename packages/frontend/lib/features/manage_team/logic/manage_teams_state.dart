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
  bool get isUsersLoading => false;
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
    List<AppUser> availableUsers = const [],
    List<AppUser>? unavailableUsers,
    this.message,
    bool isUsersLoading = false,
  }) : _teamId = teamId,
       _gameId = gameId,
       _teamName = teamName,
       _teamColor = teamColor,
       _teamSize = teamSize,
       _teamMembers = teamMembers,
       _availableUsers = availableUsers,
       _unavailableUsers = unavailableUsers ?? const [],
       _isUsersLoading = isUsersLoading;

  final String _teamId;
  final String _gameId;
  final String _teamName;
  final String _teamColor;
  final int _teamSize;
  final List<AppUser> _teamMembers;
  final List<AppUser> _availableUsers;
  final List<AppUser> _unavailableUsers;
  final bool _isUsersLoading;
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
  @override
  bool get isUsersLoading => _isUsersLoading;

  ManageTeamsLoaded copyWith({
    String? teamId,
    String? gameId,
    String? teamName,
    String? teamColor,
    int? teamSize,
    List<AppUser>? teamMembers,
    List<AppUser>? availableUsers,
    List<AppUser>? unavailableUsers,
    String? message,
    bool? isUsersLoading,
  }) {
    return ManageTeamsLoaded(
      teamId: teamId ?? _teamId,
      gameId: gameId ?? _gameId,
      teamName: teamName ?? _teamName,
      teamColor: teamColor ?? _teamColor,
      teamSize: teamSize ?? _teamSize,
      teamMembers: teamMembers ?? _teamMembers,
      availableUsers: availableUsers ?? _availableUsers,
      unavailableUsers: unavailableUsers ?? _unavailableUsers,
      message: message ?? this.message,
      isUsersLoading: isUsersLoading ?? _isUsersLoading,
    );
  }
}

@immutable
final class ManageTeamsError extends ManageTeamsState {
  const ManageTeamsError(this.message, {String? gameId}) : _gameId = gameId;

  final String message;
  final String? _gameId;

  @override
  String? get gameId => _gameId;
}
