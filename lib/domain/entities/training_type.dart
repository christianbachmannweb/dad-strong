enum TrainingType { a, b }

extension TrainingTypeDisplay on TrainingType {
  String get label => switch (this) {
        TrainingType.a => 'A',
        TrainingType.b => 'B',
      };
}
