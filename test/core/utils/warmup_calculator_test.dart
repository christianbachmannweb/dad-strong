import 'package:flutter_test/flutter_test.dart';
import 'package:dad_strong/core/utils/warmup_calculator.dart';

void main() {
  group('WarmupCalculator', () {
    test('rounds to nearest 2.5 kg', () {
      expect(roundToNearest2_5(51.0), 50.0);
      expect(roundToNearest2_5(53.0), 52.5);
      expect(roundToNearest2_5(55.0), 55.0);
    });

    test('returns only bar when last weight is 20kg or less', () {
      final steps = calculateWarmupSteps(20.0);
      expect(steps.length, 1);
      expect(steps.first.weightKg, 20.0);
    });

    test('returns 5 steps for 100kg last weight', () {
      final steps = calculateWarmupSteps(100.0);
      expect(steps.length, 5);
      expect(steps[0].weightKg, 20.0);
      expect(steps[1].weightKg, 50.0);
      expect(steps[2].weightKg, 70.0);
      expect(steps[3].weightKg, 70.0);
      expect(steps[4].weightKg, 90.0);
    });

    test('rounds 70% of 95kg correctly', () {
      final steps = calculateWarmupSteps(95.0);
      expect(steps[2].weightKg, 67.5);
    });

    test('warmup step labels are correct', () {
      final steps = calculateWarmupSteps(100.0);
      expect(steps[0].label, 'Stange');
      expect(steps[1].label, '50%');
      expect(steps[2].label, '70% × 5');
      expect(steps[3].label, '70% × 3');
      expect(steps[4].label, '90%');
    });
  });
}
