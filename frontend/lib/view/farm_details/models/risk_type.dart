enum RiskType {
  dayHeating('Day Heating', 'Temperature during day'),
  nightHeating('Night Heating', 'Temperature during night'),
  frost('Frost Risk', 'Risk of frost damage'),
  drought('Drought Risk', 'Risk of drought'),
  yiel('Yield Risk', 'Expected yield risk');

  final String displayName;
  final String description;

  const RiskType(this.displayName, this.description);
}
