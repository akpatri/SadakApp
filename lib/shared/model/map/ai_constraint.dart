class AIConstraints {
  final bool preferFastest;
  final bool preferCheapest;
  final bool avoidHighways;
  final bool prioritizeSafety;
  final double? maxBudget;

  const AIConstraints({
    this.preferFastest = false,
    this.preferCheapest = false,
    this.avoidHighways = false,
    this.prioritizeSafety = false,
    this.maxBudget,
  });

  Map<String, dynamic> toJson() => {
        'fast': preferFastest,
        'cheap': preferCheapest,
        'no_hw': avoidHighways,
        'safe': prioritizeSafety,
        'budget': maxBudget,
      };
}
