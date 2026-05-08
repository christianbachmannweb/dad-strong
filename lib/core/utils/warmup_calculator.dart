class WarmupStep {
  final double weightKg;
  final String repsLabel;

  const WarmupStep({required this.weightKg, required this.repsLabel});
}

double roundToNearest2_5(double value) {
  return (value / 2.5).round() * 2.5;
}

double _roundWhole(double value) => value.roundToDouble();

/// Full warmup: bar + 50% + 70%×5 + 70%×3 (squat, deadlift)
List<WarmupStep> calculateWarmupSteps(double lastWeightKg) {
  if (lastWeightKg <= 20) {
    return const [WarmupStep(weightKg: 20.0, repsLabel: '5')];
  }
  return [
    const WarmupStep(weightKg: 20.0, repsLabel: '5'),
    WarmupStep(weightKg: _roundWhole(lastWeightKg * 0.5), repsLabel: '5'),
    WarmupStep(weightKg: _roundWhole(lastWeightKg * 0.7), repsLabel: '5'),
    WarmupStep(weightKg: _roundWhole(lastWeightKg * 0.7), repsLabel: '3'),
  ];
}

/// Short warmup: 60%×5 + 80%×3 (bench, OHP, row)
List<WarmupStep> calculateShortWarmupSteps(double lastWeightKg) {
  if (lastWeightKg <= 20) {
    return const [WarmupStep(weightKg: 20.0, repsLabel: '5')];
  }
  return [
    WarmupStep(weightKg: _roundWhole(lastWeightKg * 0.6), repsLabel: '5'),
    WarmupStep(weightKg: _roundWhole(lastWeightKg * 0.8), repsLabel: '3'),
  ];
}
