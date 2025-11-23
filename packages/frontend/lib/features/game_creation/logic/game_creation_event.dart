import 'package:shared_models/shared_models.dart';

sealed class GameCreationEvent {
  const GameCreationEvent();
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
}

final class GameNameChanged extends GameCreationEvent {
  const GameNameChanged(this.name);

  final String name;
}

final class TeamSizeChanged extends GameCreationEvent {
  const TeamSizeChanged(this.size);

  final int size;
}

final class BoardSizeSelected extends GameCreationEvent {
  const BoardSizeSelected(this.size);

  final int size;
}

final class TileAdded extends GameCreationEvent {
  const TileAdded();
}

final class TileUpdated extends GameCreationEvent {
  const TileUpdated(this.index, this.tile);

  final int index;
  final GameTileCreation tile;
}

final class TileRemoved extends GameCreationEvent {
  const TileRemoved(this.index);

  final int index;
}

final class GameSubmitted extends GameCreationEvent {
  const GameSubmitted();
}

final class BossesLoadRequested extends GameCreationEvent {
  const BossesLoadRequested();
}
