sealed class OverviewEvent {
  const OverviewEvent();
}

final class OverviewLoadRequested extends OverviewEvent {
  const OverviewLoadRequested(this.gameId);

  final String gameId;
}
