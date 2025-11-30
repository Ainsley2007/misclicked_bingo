sealed class GuestEvent {
  const GuestEvent();
}

final class GuestGamesLoadRequested extends GuestEvent {
  const GuestGamesLoadRequested();
}

final class GuestGameOverviewLoadRequested extends GuestEvent {
  const GuestGameOverviewLoadRequested(this.gameId);

  final String gameId;
}

