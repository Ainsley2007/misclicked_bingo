enum BossType {
  easy('EASY'),
  solo('SOLO'),
  group('GROUP'),
  slayer('SLAYER');

  const BossType(this.value);
  final String value;

  static BossType fromString(String value) {
    return BossType.values.firstWhere(
      (type) => type.value == value.toUpperCase(),
      orElse: () => BossType.easy,
    );
  }
}
