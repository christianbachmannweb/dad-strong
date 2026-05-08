enum EffortLevel { none, single, double_ }

extension EffortLevelDisplay on EffortLevel {
  String get label => switch (this) {
        EffortLevel.none => '–',
        EffortLevel.single => '*',
        EffortLevel.double_ => '**',
      };
}
