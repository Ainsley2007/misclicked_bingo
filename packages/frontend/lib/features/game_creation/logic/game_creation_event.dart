import 'package:equatable/equatable.dart';

sealed class GameCreationEvent extends Equatable {
  const GameCreationEvent();

  @override
  List<Object?> get props => [];
}

final class NextStepRequested extends GameCreationEvent {
  const NextStepRequested();
}

final class PreviousStepRequested extends GameCreationEvent {
  const PreviousStepRequested();
}

final class JumpToStepRequested extends GameCreationEvent {
  const JumpToStepRequested(this.step);

  final int step;

  @override
  List<Object?> get props => [step];
}

final class GameNameChanged extends GameCreationEvent {
  const GameNameChanged(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class TeamSizeChanged extends GameCreationEvent {
  const TeamSizeChanged(this.size);

  final int size;

  @override
  List<Object?> get props => [size];
}

final class ChallengeToggleChanged extends GameCreationEvent {
  const ChallengeToggleChanged(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

final class BoardSizeSelected extends GameCreationEvent {
  const BoardSizeSelected(this.size);

  final int size;

  @override
  List<Object?> get props => [size];
}

final class ChallengeAdded extends GameCreationEvent {
  const ChallengeAdded();
}

final class ChallengeUpdated extends GameCreationEvent {
  const ChallengeUpdated(this.index, this.data);

  final int index;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [index, data];
}

final class ChallengeRemoved extends GameCreationEvent {
  const ChallengeRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class TileAdded extends GameCreationEvent {
  const TileAdded();
}

final class TileUpdated extends GameCreationEvent {
  const TileUpdated(this.index, this.data);

  final int index;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [index, data];
}

final class TileRemoved extends GameCreationEvent {
  const TileRemoved(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class GameSubmitted extends GameCreationEvent {
  const GameSubmitted();
}
