# Dad Strong – Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a minimalist Flutter strength training app with Clean Architecture, Riverpod state management, and Hive local storage that digitally replicates a physical training whiteboard.

**Architecture:** Clean Architecture (Domain / Data / Presentation). Riverpod StateNotifier manages active workout session and rest timer. Hive stores all workout history locally — no backend, no auth.

**Tech Stack:** Flutter 3.41.9, Dart 3.11.5, flutter_riverpod ^2.6.1, hive_flutter ^1.1.0, auto_route ^10.1.0, audioplayers ^6.4.0, google_fonts ^6.2.1, uuid ^4.5.1

---

## File Map

```
lib/
├── main.dart
├── bootstrap.dart
├── core/
│   ├── constants/
│   │   ├── exercises_data.dart       # hardcoded Exercise objects for A + B
│   │   └── timer_constants.dart      # all durations as named constants
│   ├── error/
│   │   └── failure.dart
│   ├── routes/
│   │   ├── app_router.dart           # auto_route config
│   │   └── app_router.gr.dart        # generated — never edit
│   ├── services/
│   │   └── audio_service.dart        # plays click + beep assets
│   ├── utils/
│   │   └── warmup_calculator.dart    # pure Dart — no Flutter deps
│   └── theme/
│       ├── app_colors.dart
│       └── app_typography.dart
├── domain/
│   ├── entities/
│   │   ├── effort_level.dart         # enum: none | single | double_
│   │   ├── exercise.dart             # name, id, repRange, type, progressionThreshold
│   │   ├── exercise_log.dart         # exerciseId + List<WorkoutSet>
│   │   ├── training_type.dart        # enum: a | b
│   │   ├── workout_session.dart      # full session entity
│   │   └── workout_set.dart          # reps, weightKg, durationSecs, effort
│   ├── repositories/
│   │   └── workout_repository.dart   # abstract interface
│   └── usecases/
│       ├── get_last_session_for_type.dart
│       ├── get_monthly_progress.dart
│       ├── save_workout_session.dart
│       └── should_show_monthly_progress.dart
├── data/
│   ├── models/
│   │   ├── workout_set_model.dart     # Hive typeId 0
│   │   ├── exercise_log_model.dart    # Hive typeId 1
│   │   └── workout_session_model.dart # Hive typeId 2
│   ├── datasources/
│   │   └── workout_local_datasource.dart
│   ├── repositories/
│   │   └── workout_repository_impl.dart
│   └── seed/
│       └── seed_data.dart            # whiteboard values for first run
└── presentation/
    ├── providers/
    │   ├── workout_repository_provider.dart
    │   ├── training_history_provider.dart
    │   ├── workout_session_provider.dart  # StateNotifier — active session
    │   └── rest_timer_provider.dart       # StateNotifier — countdown
    ├── pages/
    │   ├── home/
    │   │   └── home_page.dart
    │   ├── workout/
    │   │   ├── view/workout_page.dart         # orchestrator — shows correct widget per phase
    │   │   └── widgets/
    │   │       ├── general_warmup_widget.dart
    │   │       ├── specific_warmup_widget.dart
    │   │       ├── set_screen_widget.dart
    │   │       ├── rest_screen_widget.dart
    │   │       └── exercise_transition_widget.dart
    │   ├── summary/
    │   │   └── summary_page.dart
    │   └── monthly_progress/
    │       └── monthly_progress_page.dart
    └── widgets/
        ├── ring_timer_widget.dart     # reusable circular countdown
        ├── scroll_picker_widget.dart  # ListWheelScrollView picker
        └── effort_marker_widget.dart  # –  /  *  /  **  toggle

test/
├── core/utils/warmup_calculator_test.dart
└── domain/usecases/
    ├── get_monthly_progress_test.dart
    └── should_show_monthly_progress_test.dart

assets/
├── audio/
│   ├── click.mp3    # frosch-klicker sound (10s warning)
│   └── beep.mp3     # end-of-timer beep
```

---

## Task 1: Flutter scaffold + pubspec.yaml

**Files:**
- Create: `pubspec.yaml` (replace generated)
- Create: `assets/audio/click.mp3` (placeholder)
- Create: `assets/audio/beep.mp3` (placeholder)

- [ ] **Step 1: Create the Flutter project**

```bash
cd /Users/christianbachmann/Development/projects/dad-strong_app
flutter create --org com.christianbachmann --project-name dad_strong . --platforms ios,android
```

Expected: Flutter project created with lib/main.dart, ios/, android/ etc.

- [ ] **Step 2: Replace pubspec.yaml**

```yaml
name: dad_strong
description: Minimalist strength training tracker.
publish_to: none
version: 1.0.0+1

environment:
  sdk: ^3.11.0

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  hive_flutter: ^1.1.0
  auto_route: ^10.1.0
  audioplayers: ^6.4.0
  google_fonts: ^6.2.1
  uuid: ^4.5.1
  path_provider: ^2.1.5
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  hive_generator: ^2.0.1
  auto_route_generator: ^10.2.3
  build_runner: ^2.4.15

flutter:
  uses-material-design: true
  assets:
    - assets/audio/
```

- [ ] **Step 3: Create audio asset placeholders**

```bash
mkdir -p assets/audio
# Add real click.mp3 and beep.mp3 files here.
# For now create empty placeholders so pubspec resolves:
touch assets/audio/click.mp3
touch assets/audio/beep.mp3
```

Note: Replace these with real audio files before testing sound. Free sources: freesound.org — search "click" and "beep".

- [ ] **Step 4: Install dependencies**

```bash
flutter pub get
```

Expected: Resolving dependencies... Got dependencies!

- [ ] **Step 5: Clear generated main.dart**

Replace `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Dad Strong')))));
}
```

- [ ] **Step 6: Verify it compiles**

```bash
flutter build apk --debug 2>&1 | tail -5
```

Expected: Built build/app/outputs/flutter-apk/app-debug.apk

- [ ] **Step 7: Commit**

```bash
git init
git add pubspec.yaml pubspec.lock assets/ lib/main.dart
git commit -m "chore: scaffold Flutter project with dependencies"
```

---

## Task 2: Core theme

**Files:**
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_typography.dart`

- [ ] **Step 1: Create app_colors.dart**

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF0A0A0A);
  static const surface = Color(0xFF141414);
  static const accent = Color(0xFFE8E8E8);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF666666);
  static const timerRingActive = Color(0xFFFFFFFF);
  static const timerRingBackground = Color(0xFF1E1E1E);
  static const effortGold = Color(0xFFC8A951);
}

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme.dark(
    surface: AppColors.background,
    primary: AppColors.textPrimary,
    secondary: AppColors.textSecondary,
  ),
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
);
```

- [ ] **Step 2: Create app_typography.dart**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 64,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1,
      );

  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/core/theme/
git commit -m "feat: add theme colors and typography"
```

---

## Task 3: Core constants

**Files:**
- Create: `lib/core/constants/timer_constants.dart`
- Create: `lib/core/constants/exercises_data.dart`
- Create: `lib/domain/entities/effort_level.dart`
- Create: `lib/domain/entities/exercise.dart`
- Create: `lib/domain/entities/training_type.dart`

- [ ] **Step 1: Create effort_level.dart**

```dart
enum EffortLevel { none, single, double_ }

extension EffortLevelDisplay on EffortLevel {
  String get label => switch (this) {
        EffortLevel.none => '–',
        EffortLevel.single => '*',
        EffortLevel.double_ => '**',
      };
}
```

- [ ] **Step 2: Create training_type.dart**

```dart
enum TrainingType { a, b }

extension TrainingTypeDisplay on TrainingType {
  String get label => switch (this) {
        TrainingType.a => 'A',
        TrainingType.b => 'B',
      };
}
```

- [ ] **Step 3: Create exercise.dart**

```dart
enum ExerciseType { barbell, dumbbell, bodyweight, timedCarry }

class Exercise {
  final String id;
  final String name;
  final int workSets;
  final int repMin;
  final int repMax;
  final int progressionThreshold; // reps needed to earn * marker suggestion
  final ExerciseType type;
  final bool isBilateral; // left then right
  final bool isTimeBased; // farmer walk — 60s per side
  final bool hasSpecificWarmup; // only first exercise per training

  const Exercise({
    required this.id,
    required this.name,
    required this.workSets,
    required this.repMin,
    required this.repMax,
    required this.progressionThreshold,
    required this.type,
    this.isBilateral = false,
    this.isTimeBased = false,
    this.hasSpecificWarmup = false,
  });
}
```

- [ ] **Step 4: Create timer_constants.dart**

```dart
abstract final class TimerConstants {
  static const generalWarmupWorkSeconds = 30;
  static const generalWarmupRestSeconds = 5;
  static const generalWarmupRounds = 5;

  static const specificWarmupRestSeconds = 90; // 1:30 between warmup sets

  static const workSetRestSeconds = 180; // 3 min
  static const bilateralRestSeconds = 60; // 1 min between legs
  static const exerciseTransitionSeconds = 120; // 2 min, skippable

  static const timerWarningSeconds = 10; // frosch-klicker starts
  static const farmerWalkDurationSeconds = 60;
}
```

- [ ] **Step 5: Create exercises_data.dart**

```dart
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/training_type.dart';

abstract final class ExercisesData {
  static const List<Exercise> trainingA = [
    Exercise(
      id: 'squat',
      name: 'LH-Kniebeuge',
      workSets: 2,
      repMin: 4,
      repMax: 8,
      progressionThreshold: 8,
      type: ExerciseType.barbell,
      hasSpecificWarmup: true,
    ),
    Exercise(
      id: 'bench',
      name: 'LH-Bankdrücken',
      workSets: 2,
      repMin: 4,
      repMax: 8,
      progressionThreshold: 8,
      type: ExerciseType.barbell,
    ),
    Exercise(
      id: 'row',
      name: 'LH-Rudern',
      workSets: 2,
      repMin: 4,
      repMax: 8,
      progressionThreshold: 8,
      type: ExerciseType.barbell,
    ),
    Exercise(
      id: 'bss',
      name: 'KH-Bulg. Split Squat',
      workSets: 1,
      repMin: 6,
      repMax: 10,
      progressionThreshold: 10,
      type: ExerciseType.dumbbell,
      isBilateral: true,
    ),
    Exercise(
      id: 'farmer',
      name: 'Farmer Walk',
      workSets: 1,
      repMin: 0,
      repMax: 0,
      progressionThreshold: 0,
      type: ExerciseType.timedCarry,
      isBilateral: true,
      isTimeBased: true,
    ),
  ];

  static const List<Exercise> trainingB = [
    Exercise(
      id: 'deadlift',
      name: 'LH-Kreuzheben',
      workSets: 2,
      repMin: 4,
      repMax: 6,
      progressionThreshold: 6,
      type: ExerciseType.barbell,
      hasSpecificWarmup: true,
    ),
    Exercise(
      id: 'ohp',
      name: 'LH-Schulterdrücken',
      workSets: 2,
      repMin: 4,
      repMax: 8,
      progressionThreshold: 8,
      type: ExerciseType.barbell,
    ),
    Exercise(
      id: 'pullup',
      name: 'Klimmzüge',
      workSets: 2,
      repMin: 6,
      repMax: 10,
      progressionThreshold: 10,
      type: ExerciseType.bodyweight,
    ),
    Exercise(
      id: 'stepup',
      name: 'KH-Step-Up',
      workSets: 1,
      repMin: 6,
      repMax: 10,
      progressionThreshold: 10,
      type: ExerciseType.dumbbell,
      isBilateral: true,
    ),
  ];

  static List<Exercise> forType(TrainingType type) =>
      type == TrainingType.a ? trainingA : trainingB;
}
```

- [ ] **Step 6: Commit**

```bash
git add lib/core/constants/ lib/domain/entities/
git commit -m "feat: add core constants and exercise definitions"
```

---

## Task 4: Warmup calculator (with unit tests)

**Files:**
- Create: `lib/core/utils/warmup_calculator.dart`
- Create: `test/core/utils/warmup_calculator_test.dart`

- [ ] **Step 1: Write the failing tests first**

```dart
// test/core/utils/warmup_calculator_test.dart
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
      expect(steps[0].weightKg, 20.0);  // bar
      expect(steps[1].weightKg, 50.0);  // 50%
      expect(steps[2].weightKg, 70.0);  // 70%x5
      expect(steps[3].weightKg, 70.0);  // 70%x3
      expect(steps[4].weightKg, 90.0);  // 90%
    });

    test('rounds 70% of 95kg correctly', () {
      final steps = calculateWarmupSteps(95.0);
      // 95 * 0.7 = 66.5 → rounds to 67.5
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
```

- [ ] **Step 2: Run test — verify it fails**

```bash
flutter test test/core/utils/warmup_calculator_test.dart
```

Expected: FAIL — file not found

- [ ] **Step 3: Implement warmup_calculator.dart**

```dart
// lib/core/utils/warmup_calculator.dart

class WarmupStep {
  final double weightKg;
  final String repsLabel; // e.g. "5", "3", "1-2"
  final String label;     // e.g. "50%", "Stange"

  const WarmupStep({
    required this.weightKg,
    required this.repsLabel,
    required this.label,
  });
}

double roundToNearest2_5(double value) {
  return (value / 2.5).round() * 2.5;
}

List<WarmupStep> calculateWarmupSteps(double lastWeightKg) {
  if (lastWeightKg <= 20) {
    return const [
      WarmupStep(weightKg: 20.0, repsLabel: '5', label: 'Stange'),
    ];
  }
  return [
    const WarmupStep(weightKg: 20.0, repsLabel: '5', label: 'Stange'),
    WarmupStep(
      weightKg: roundToNearest2_5(lastWeightKg * 0.5),
      repsLabel: '5',
      label: '50%',
    ),
    WarmupStep(
      weightKg: roundToNearest2_5(lastWeightKg * 0.7),
      repsLabel: '5',
      label: '70% × 5',
    ),
    WarmupStep(
      weightKg: roundToNearest2_5(lastWeightKg * 0.7),
      repsLabel: '3',
      label: '70% × 3',
    ),
    WarmupStep(
      weightKg: roundToNearest2_5(lastWeightKg * 0.9),
      repsLabel: '1-2',
      label: '90%',
    ),
  ];
}
```

- [ ] **Step 4: Run tests — verify they pass**

```bash
flutter test test/core/utils/warmup_calculator_test.dart
```

Expected: All 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/utils/ test/
git commit -m "feat: add warmup calculator with tests"
```

---

## Task 5: Domain entities + repository interface

**Files:**
- Create: `lib/domain/entities/workout_set.dart`
- Create: `lib/domain/entities/exercise_log.dart`
- Create: `lib/domain/entities/workout_session.dart`
- Create: `lib/domain/repositories/workout_repository.dart`

- [ ] **Step 1: Create workout_set.dart**

```dart
import 'effort_level.dart';

class WorkoutSet {
  final int setIndex;
  final int reps;
  final double weightKg;
  final int durationSeconds; // 0 for rep-based
  final EffortLevel effort;

  const WorkoutSet({
    required this.setIndex,
    required this.reps,
    required this.weightKg,
    this.durationSeconds = 0,
    this.effort = EffortLevel.none,
  });

  String get displayLabel {
    final weightStr = weightKg == 0
        ? 'BK'
        : '${weightKg % 1 == 0 ? weightKg.toInt() : weightKg} kg';
    if (durationSeconds > 0) {
      return '${durationSeconds}s × $weightStr${effort == EffortLevel.none ? '' : ' ${effort.label}'}';
    }
    return '$reps × $weightStr${effort == EffortLevel.none ? '' : ' ${effort.label}'}';
  }
}
```

- [ ] **Step 2: Create exercise_log.dart**

```dart
import 'workout_set.dart';

class ExerciseLog {
  final String exerciseId;
  final List<WorkoutSet> sets;

  const ExerciseLog({required this.exerciseId, required this.sets});

  double get bestWeightKg =>
      sets.isEmpty ? 0 : sets.map((s) => s.weightKg).reduce((a, b) => a > b ? a : b);

  int get bestReps =>
      sets.isEmpty ? 0 : sets.map((s) => s.reps).reduce((a, b) => a > b ? a : b);
}
```

- [ ] **Step 3: Create workout_session.dart**

```dart
import 'exercise_log.dart';
import 'training_type.dart';

class WorkoutSession {
  final String id;
  final TrainingType type;
  final DateTime date;
  final int totalDurationSeconds;
  final List<ExerciseLog> exerciseLogs;

  const WorkoutSession({
    required this.id,
    required this.type,
    required this.date,
    required this.totalDurationSeconds,
    required this.exerciseLogs,
  });

  ExerciseLog? logFor(String exerciseId) {
    try {
      return exerciseLogs.firstWhere((l) => l.exerciseId == exerciseId);
    } catch (_) {
      return null;
    }
  }
}
```

- [ ] **Step 4: Create workout_repository.dart**

```dart
import '../entities/training_type.dart';
import '../entities/workout_session.dart';

abstract interface class WorkoutRepository {
  Future<void> saveSession(WorkoutSession session);
  Future<List<WorkoutSession>> getAllSessions();
  Future<WorkoutSession?> getLastSessionForType(TrainingType type);
  Future<bool> isFirstRun();
  Future<void> markSeeded();
}
```

- [ ] **Step 5: Commit**

```bash
git add lib/domain/
git commit -m "feat: add domain entities and repository interface"
```

---

## Task 6: Domain use cases (with tests)

**Files:**
- Create: `lib/domain/usecases/save_workout_session.dart`
- Create: `lib/domain/usecases/get_last_session_for_type.dart`
- Create: `lib/domain/usecases/get_monthly_progress.dart`
- Create: `lib/domain/usecases/should_show_monthly_progress.dart`
- Create: `test/domain/usecases/get_monthly_progress_test.dart`
- Create: `test/domain/usecases/should_show_monthly_progress_test.dart`

- [ ] **Step 1: Create save_workout_session.dart**

```dart
import '../entities/workout_session.dart';
import '../repositories/workout_repository.dart';

class SaveWorkoutSession {
  final WorkoutRepository _repo;
  const SaveWorkoutSession(this._repo);

  Future<void> execute(WorkoutSession session) => _repo.saveSession(session);
}
```

- [ ] **Step 2: Create get_last_session_for_type.dart**

```dart
import '../entities/training_type.dart';
import '../entities/workout_session.dart';
import '../repositories/workout_repository.dart';

class GetLastSessionForType {
  final WorkoutRepository _repo;
  const GetLastSessionForType(this._repo);

  Future<WorkoutSession?> execute(TrainingType type) =>
      _repo.getLastSessionForType(type);
}
```

- [ ] **Step 3: Create get_monthly_progress.dart**

```dart
import '../entities/workout_session.dart';
import '../repositories/workout_repository.dart';

/// Returns map of exerciseId → % change (0.15 = +15%).
/// Compares best weight in first week of previous month
/// vs best weight in last week of previous month.
/// Returns null if not enough data.
class GetMonthlyProgress {
  final WorkoutRepository _repo;
  const GetMonthlyProgress(this._repo);

  Future<Map<String, double>?> execute() async {
    final now = DateTime.now();
    final firstOfPrevMonth = DateTime(now.year, now.month - 1, 1);
    final firstOfThisMonth = DateTime(now.year, now.month, 1);

    final allSessions = await _repo.getAllSessions();

    final prevMonthSessions = allSessions
        .where((s) =>
            s.date.isAfter(firstOfPrevMonth.subtract(const Duration(seconds: 1))) &&
            s.date.isBefore(firstOfThisMonth))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (prevMonthSessions.length < 2) return null;

    final firstWeekEnd = firstOfPrevMonth.add(const Duration(days: 7));
    final firstWeek = prevMonthSessions.where((s) => s.date.isBefore(firstWeekEnd)).toList();
    final lastWeek = prevMonthSessions.reversed
        .takeWhile((s) => s.date.isAfter(
            firstOfThisMonth.subtract(const Duration(days: 7))))
        .toList();

    if (firstWeek.isEmpty || lastWeek.isEmpty) return null;

    final result = <String, double>{};

    final allExerciseIds = allSessions
        .expand((s) => s.exerciseLogs.map((l) => l.exerciseId))
        .toSet();

    for (final id in allExerciseIds) {
      final startBest = firstWeek
          .expand((s) => s.exerciseLogs.where((l) => l.exerciseId == id))
          .map((l) => l.bestWeightKg)
          .fold(0.0, (a, b) => a > b ? a : b);

      final endBest = lastWeek
          .expand((s) => s.exerciseLogs.where((l) => l.exerciseId == id))
          .map((l) => l.bestWeightKg)
          .fold(0.0, (a, b) => a > b ? a : b);

      if (startBest > 0) {
        result[id] = (endBest - startBest) / startBest;
      }
    }

    return result.isEmpty ? null : result;
  }
}
```

- [ ] **Step 4: Create should_show_monthly_progress.dart**

```dart
import '../repositories/workout_repository.dart';

class ShouldShowMonthlyProgress {
  final WorkoutRepository _repo;
  const ShouldShowMonthlyProgress(this._repo);

  Future<bool> execute() async {
    final now = DateTime.now();
    final firstOfThisMonth = DateTime(now.year, now.month, 1);
    final firstOfPrevMonth = DateTime(now.year, now.month - 1, 1);

    final sessions = await _repo.getAllSessions();

    // Only show on first training day of a new month
    final hasTrainedThisMonth = sessions.any((s) =>
        s.date.isAfter(firstOfThisMonth.subtract(const Duration(seconds: 1))));
    if (hasTrainedThisMonth) return false;

    // Need at least 2 sessions in prev month
    final prevMonthCount = sessions
        .where((s) =>
            s.date.isAfter(firstOfPrevMonth.subtract(const Duration(seconds: 1))) &&
            s.date.isBefore(firstOfThisMonth))
        .length;

    return prevMonthCount >= 2;
  }
}
```

- [ ] **Step 5: Write tests**

```dart
// test/domain/usecases/should_show_monthly_progress_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dad_strong/domain/entities/training_type.dart';
import 'package:dad_strong/domain/entities/workout_session.dart';
import 'package:dad_strong/domain/usecases/should_show_monthly_progress.dart';
import 'package:dad_strong/domain/repositories/workout_repository.dart';

class _FakeRepo implements WorkoutRepository {
  final List<WorkoutSession> sessions;
  _FakeRepo(this.sessions);

  @override Future<List<WorkoutSession>> getAllSessions() async => sessions;
  @override Future<WorkoutSession?> getLastSessionForType(TrainingType t) async => null;
  @override Future<void> saveSession(WorkoutSession s) async {}
  @override Future<bool> isFirstRun() async => false;
  @override Future<void> markSeeded() async {}
}

WorkoutSession _session(DateTime date) => WorkoutSession(
      id: date.toString(),
      type: TrainingType.a,
      date: date,
      totalDurationSeconds: 3600,
      exerciseLogs: const [],
    );

void main() {
  final now = DateTime.now();
  final prevMonth = DateTime(now.year, now.month - 1);

  test('returns true when no sessions this month and 2+ last month', () async {
    final repo = _FakeRepo([
      _session(DateTime(prevMonth.year, prevMonth.month, 5)),
      _session(DateTime(prevMonth.year, prevMonth.month, 20)),
    ]);
    final result = await ShouldShowMonthlyProgress(repo).execute();
    expect(result, true);
  });

  test('returns false when already trained this month', () async {
    final repo = _FakeRepo([
      _session(DateTime(prevMonth.year, prevMonth.month, 5)),
      _session(DateTime(prevMonth.year, prevMonth.month, 20)),
      _session(DateTime(now.year, now.month, 1)),
    ]);
    final result = await ShouldShowMonthlyProgress(repo).execute();
    expect(result, false);
  });

  test('returns false when only 1 session last month', () async {
    final repo = _FakeRepo([
      _session(DateTime(prevMonth.year, prevMonth.month, 10)),
    ]);
    final result = await ShouldShowMonthlyProgress(repo).execute();
    expect(result, false);
  });
}
```

- [ ] **Step 6: Run tests**

```bash
flutter test test/domain/usecases/should_show_monthly_progress_test.dart
```

Expected: All 3 tests pass.

- [ ] **Step 7: Commit**

```bash
git add lib/domain/usecases/ test/domain/
git commit -m "feat: add domain use cases with tests"
```

---

## Task 7: Hive data models + code generation

**Files:**
- Create: `lib/data/models/workout_set_model.dart`
- Create: `lib/data/models/exercise_log_model.dart`
- Create: `lib/data/models/workout_session_model.dart`

- [ ] **Step 1: Create workout_set_model.dart**

```dart
import 'package:hive_flutter/hive_flutter.dart';
part 'workout_set_model.g.dart';

@HiveType(typeId: 0)
class WorkoutSetModel extends HiveObject {
  @HiveField(0) int setIndex;
  @HiveField(1) int reps;
  @HiveField(2) double weightKg;
  @HiveField(3) int durationSeconds;
  @HiveField(4) int effortIndex; // 0=none, 1=single, 2=double_

  WorkoutSetModel({
    required this.setIndex,
    required this.reps,
    required this.weightKg,
    required this.durationSeconds,
    required this.effortIndex,
  });
}
```

- [ ] **Step 2: Create exercise_log_model.dart**

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'workout_set_model.dart';
part 'exercise_log_model.g.dart';

@HiveType(typeId: 1)
class ExerciseLogModel extends HiveObject {
  @HiveField(0) String exerciseId;
  @HiveField(1) List<WorkoutSetModel> sets;

  ExerciseLogModel({required this.exerciseId, required this.sets});
}
```

- [ ] **Step 3: Create workout_session_model.dart**

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'exercise_log_model.dart';
part 'workout_session_model.g.dart';

@HiveType(typeId: 2)
class WorkoutSessionModel extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) int typeIndex;  // 0=A, 1=B
  @HiveField(2) DateTime date;
  @HiveField(3) int totalDurationSeconds;
  @HiveField(4) List<ExerciseLogModel> exerciseLogs;

  WorkoutSessionModel({
    required this.id,
    required this.typeIndex,
    required this.date,
    required this.totalDurationSeconds,
    required this.exerciseLogs,
  });
}
```

- [ ] **Step 4: Run code generator**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: Creates `workout_set_model.g.dart`, `exercise_log_model.g.dart`, `workout_session_model.g.dart`

- [ ] **Step 5: Commit**

```bash
git add lib/data/models/
git commit -m "feat: add Hive data models and generate adapters"
```

---

## Task 8: Local datasource + repository implementation

**Files:**
- Create: `lib/data/datasources/workout_local_datasource.dart`
- Create: `lib/data/repositories/workout_repository_impl.dart`

- [ ] **Step 1: Create workout_local_datasource.dart**

```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_session_model.dart';

class WorkoutLocalDatasource {
  static const _sessionsBoxName = 'workout_sessions';
  static const _metaBoxName = 'meta';
  static const _seededKey = 'seeded';

  Box<WorkoutSessionModel> get _sessionsBox =>
      Hive.box<WorkoutSessionModel>(_sessionsBoxName);

  Box<dynamic> get _metaBox => Hive.box<dynamic>(_metaBoxName);

  static Future<void> openBoxes() async {
    await Hive.openBox<WorkoutSessionModel>(_sessionsBoxName);
    await Hive.openBox<dynamic>(_metaBoxName);
  }

  Future<void> saveSession(WorkoutSessionModel model) async {
    await _sessionsBox.put(model.id, model);
  }

  List<WorkoutSessionModel> getAllSessions() {
    return _sessionsBox.values.toList();
  }

  bool isFirstRun() => !(_metaBox.get(_seededKey, defaultValue: false) as bool);

  Future<void> markSeeded() => _metaBox.put(_seededKey, true);
}
```

- [ ] **Step 2: Create workout_repository_impl.dart**

```dart
import '../../domain/entities/effort_level.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/training_type.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_set.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_local_datasource.dart';
import '../models/exercise_log_model.dart';
import '../models/workout_session_model.dart';
import '../models/workout_set_model.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutLocalDatasource _datasource;
  const WorkoutRepositoryImpl(this._datasource);

  @override
  Future<void> saveSession(WorkoutSession session) =>
      _datasource.saveSession(_toModel(session));

  @override
  Future<List<WorkoutSession>> getAllSessions() async {
    return _datasource.getAllSessions().map(_toDomain).toList();
  }

  @override
  Future<WorkoutSession?> getLastSessionForType(TrainingType type) async {
    final sessions = _datasource
        .getAllSessions()
        .where((m) => m.typeIndex == type.index)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (sessions.isEmpty) return null;
    return _toDomain(sessions.first);
  }

  @override
  Future<bool> isFirstRun() async => _datasource.isFirstRun();

  @override
  Future<void> markSeeded() => _datasource.markSeeded();

  // --- Mappers ---

  WorkoutSession _toDomain(WorkoutSessionModel m) => WorkoutSession(
        id: m.id,
        type: TrainingType.values[m.typeIndex],
        date: m.date,
        totalDurationSeconds: m.totalDurationSeconds,
        exerciseLogs: m.exerciseLogs.map(_logToDomain).toList(),
      );

  ExerciseLog _logToDomain(ExerciseLogModel m) => ExerciseLog(
        exerciseId: m.exerciseId,
        sets: m.sets.map(_setToDomain).toList(),
      );

  WorkoutSet _setToDomain(WorkoutSetModel m) => WorkoutSet(
        setIndex: m.setIndex,
        reps: m.reps,
        weightKg: m.weightKg,
        durationSeconds: m.durationSeconds,
        effort: EffortLevel.values[m.effortIndex],
      );

  WorkoutSessionModel _toModel(WorkoutSession s) => WorkoutSessionModel(
        id: s.id,
        typeIndex: s.type.index,
        date: s.date,
        totalDurationSeconds: s.totalDurationSeconds,
        exerciseLogs: s.exerciseLogs.map(_logToModel).toList(),
      );

  ExerciseLogModel _logToModel(ExerciseLog l) => ExerciseLogModel(
        exerciseId: l.exerciseId,
        sets: l.sets.map(_setToModel).toList(),
      );

  WorkoutSetModel _setToModel(WorkoutSet s) => WorkoutSetModel(
        setIndex: s.setIndex,
        reps: s.reps,
        weightKg: s.weightKg,
        durationSeconds: s.durationSeconds,
        effortIndex: s.effort.index,
      );
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/data/
git commit -m "feat: add Hive datasource and repository implementation"
```

---

## Task 9: Seed data + bootstrap + main.dart

**Files:**
- Create: `lib/data/seed/seed_data.dart`
- Create: `lib/bootstrap.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Create seed_data.dart**

```dart
import 'package:uuid/uuid.dart';
import '../../domain/entities/effort_level.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/training_type.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_set.dart';

final _uuid = Uuid();

WorkoutSession seedSessionA() => WorkoutSession(
      id: _uuid.v4(),
      type: TrainingType.a,
      date: DateTime(2026, 5, 5),
      totalDurationSeconds: 3900,
      exerciseLogs: [
        ExerciseLog(exerciseId: 'squat', sets: [
          WorkoutSet(setIndex: 0, reps: 6, weightKg: 100),
          WorkoutSet(setIndex: 1, reps: 5, weightKg: 100),
        ]),
        ExerciseLog(exerciseId: 'bench', sets: [
          WorkoutSet(setIndex: 0, reps: 8, weightKg: 100),
          WorkoutSet(setIndex: 1, reps: 8, weightKg: 100),
        ]),
        ExerciseLog(exerciseId: 'row', sets: [
          WorkoutSet(setIndex: 0, reps: 8, weightKg: 100),
          WorkoutSet(setIndex: 1, reps: 8, weightKg: 100),
        ]),
        ExerciseLog(exerciseId: 'bss', sets: [
          WorkoutSet(setIndex: 0, reps: 3, weightKg: 60), // left
          WorkoutSet(setIndex: 1, reps: 3, weightKg: 60), // right
        ]),
        ExerciseLog(exerciseId: 'farmer', sets: [
          WorkoutSet(setIndex: 0, reps: 0, weightKg: 20, durationSeconds: 60),
          WorkoutSet(setIndex: 1, reps: 0, weightKg: 20, durationSeconds: 60),
        ]),
      ],
    );

WorkoutSession seedSessionB() => WorkoutSession(
      id: _uuid.v4(),
      type: TrainingType.b,
      date: DateTime(2026, 5, 1),
      totalDurationSeconds: 3600,
      exerciseLogs: [
        ExerciseLog(exerciseId: 'deadlift', sets: [
          WorkoutSet(setIndex: 0, reps: 6, weightKg: 100),
          WorkoutSet(setIndex: 1, reps: 6, weightKg: 100),
        ]),
        ExerciseLog(exerciseId: 'ohp', sets: [
          WorkoutSet(setIndex: 0, reps: 8, weightKg: 100),
          WorkoutSet(setIndex: 1, reps: 8, weightKg: 100),
        ]),
        ExerciseLog(exerciseId: 'pullup', sets: [
          WorkoutSet(setIndex: 0, reps: 8, weightKg: 0),
          WorkoutSet(setIndex: 1, reps: 8, weightKg: 0),
        ]),
        ExerciseLog(exerciseId: 'stepup', sets: [
          WorkoutSet(setIndex: 0, reps: 3, weightKg: 60), // left
          WorkoutSet(setIndex: 1, reps: 3, weightKg: 60), // right
        ]),
      ],
    );
```

- [ ] **Step 2: Create bootstrap.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/datasources/workout_local_datasource.dart';
import 'data/models/exercise_log_model.dart';
import 'data/models/workout_session_model.dart';
import 'data/models/workout_set_model.dart';
import 'data/repositories/workout_repository_impl.dart';
import 'data/seed/seed_data.dart';
import 'presentation/app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutSetModelAdapter());
  Hive.registerAdapter(ExerciseLogModelAdapter());
  Hive.registerAdapter(WorkoutSessionModelAdapter());
  await WorkoutLocalDatasource.openBoxes();

  final datasource = WorkoutLocalDatasource();
  if (datasource.isFirstRun()) {
    final repo = WorkoutRepositoryImpl(datasource);
    await repo.saveSession(seedSessionA());
    await repo.saveSession(seedSessionB());
    await datasource.markSeeded();
  }

  runApp(const ProviderScope(child: App()));
}
```

- [ ] **Step 3: Update main.dart**

```dart
import 'bootstrap.dart';

void main() => bootstrap();
```

- [ ] **Step 4: Create lib/presentation/app.dart (stub)**

```dart
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dad Strong',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const Scaffold(
        body: Center(child: Text('Dad Strong', style: TextStyle(color: Colors.white))),
      ),
    );
  }
}
```

- [ ] **Step 5: Run on simulator to verify boot**

```bash
flutter run
```

Expected: App launches, shows "Dad Strong" on black screen. No errors in console.

- [ ] **Step 6: Commit**

```bash
git add lib/
git commit -m "feat: add seed data, Hive bootstrap, and app entry point"
```

---

## Task 10: Auto_route navigation setup

**Files:**
- Create: `lib/core/routes/app_router.dart`
- Modify: `lib/presentation/app.dart`
- Create stub pages: `home_page.dart`, `workout_page.dart`, `summary_page.dart`, `monthly_progress_page.dart`

- [ ] **Step 1: Create stub pages**

Create `lib/presentation/pages/home/home_page.dart`:
```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text('Home', style: TextStyle(color: Colors.white))),
    );
  }
}
```

Create `lib/presentation/pages/workout/view/workout_page.dart`:
```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/entities/training_type.dart';

@RoutePage()
class WorkoutPage extends StatelessWidget {
  final TrainingType trainingType;
  const WorkoutPage({required this.trainingType, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text('Workout ${trainingType.label}',
          style: const TextStyle(color: Colors.white))),
    );
  }
}
```

Create `lib/presentation/pages/summary/summary_page.dart`:
```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Summary')));
}
```

Create `lib/presentation/pages/monthly_progress/monthly_progress_page.dart`:
```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MonthlyProgressPage extends StatelessWidget {
  const MonthlyProgressPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Monthly Progress')));
}
```

- [ ] **Step 2: Create app_router.dart**

```dart
import 'package:auto_route/auto_route.dart';
import '../../domain/entities/training_type.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/monthly_progress/monthly_progress_page.dart';
import '../../presentation/pages/summary/summary_page.dart';
import '../../presentation/pages/workout/view/workout_page.dart';
part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: WorkoutRoute.page),
        AutoRoute(page: SummaryRoute.page),
        AutoRoute(page: MonthlyProgressRoute.page),
      ];
}
```

- [ ] **Step 3: Run build_runner**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: Creates `app_router.gr.dart`

- [ ] **Step 4: Wire router into app.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/routes/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

final _router = AppRouter();

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Dad Strong',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: TextTheme(bodyMedium: AppTypography.bodyMedium),
      ),
      routerConfig: _router.config(),
    );
  }
}
```

- [ ] **Step 5: Run on simulator**

```bash
flutter run
```

Expected: App launches, shows HomeScreen stub.

- [ ] **Step 6: Commit**

```bash
git add lib/core/routes/ lib/presentation/
git commit -m "feat: add auto_route navigation with stub pages"
```

---

## Task 11: Riverpod providers

**Files:**
- Create: `lib/presentation/providers/workout_repository_provider.dart`
- Create: `lib/presentation/providers/training_history_provider.dart`
- Create: `lib/presentation/providers/rest_timer_provider.dart`
- Create: `lib/presentation/providers/workout_session_provider.dart`

- [ ] **Step 1: Create workout_repository_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/workout_local_datasource.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/repositories/workout_repository.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepositoryImpl(WorkoutLocalDatasource());
});
```

- [ ] **Step 2: Create training_history_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/training_type.dart';
import '../../domain/entities/workout_session.dart';
import 'workout_repository_provider.dart';

final trainingHistoryProvider =
    FutureProvider<List<WorkoutSession>>((ref) async {
  final repo = ref.read(workoutRepositoryProvider);
  return repo.getAllSessions();
});

final lastSessionForTypeProvider =
    FutureProvider.family<WorkoutSession?, TrainingType>((ref, type) async {
  final repo = ref.read(workoutRepositoryProvider);
  return repo.getLastSessionForType(type);
});
```

- [ ] **Step 3: Create rest_timer_provider.dart**

```dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/timer_constants.dart';
import '../../core/services/audio_service.dart';

class RestTimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final bool isComplete;

  const RestTimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    this.isRunning = false,
    this.isComplete = false,
  });

  double get progress => remainingSeconds / totalSeconds;
  bool get isWarning =>
      remainingSeconds <= TimerConstants.timerWarningSeconds && remainingSeconds > 0;
}

class RestTimerNotifier extends StateNotifier<RestTimerState> {
  Timer? _timer;
  final AudioService _audio;
  void Function()? onComplete;

  RestTimerNotifier(this._audio)
      : super(const RestTimerState(totalSeconds: 180, remainingSeconds: 180));

  void start(int seconds, {void Function()? onComplete}) {
    _timer?.cancel();
    this.onComplete = onComplete;
    state = RestTimerState(totalSeconds: seconds, remainingSeconds: seconds, isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer t) {
    final remaining = state.remainingSeconds - 1;
    if (remaining == TimerConstants.timerWarningSeconds) _audio.playClick();
    if (remaining <= 0) {
      _timer?.cancel();
      _audio.playBeep();
      state = RestTimerState(
        totalSeconds: state.totalSeconds,
        remainingSeconds: 0,
        isRunning: false,
        isComplete: true,
      );
      onComplete?.call();
    } else {
      state = RestTimerState(
        totalSeconds: state.totalSeconds,
        remainingSeconds: remaining,
        isRunning: true,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final restTimerProvider =
    StateNotifierProvider<RestTimerNotifier, RestTimerState>((ref) {
  return RestTimerNotifier(AudioService());
});
```

- [ ] **Step 4: Create audio_service.dart**

```dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final _player = AudioPlayer();

  Future<void> playClick() async {
    await _player.play(AssetSource('audio/click.mp3'));
  }

  Future<void> playBeep() async {
    await _player.play(AssetSource('audio/beep.mp3'));
  }
}
```

- [ ] **Step 5: Create workout_session_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/exercises_data.dart';
import '../../domain/entities/effort_level.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/training_type.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_set.dart';
import '../../domain/usecases/save_workout_session.dart';
import 'workout_repository_provider.dart';
import 'package:uuid/uuid.dart';

enum WorkoutPhase {
  generalWarmup,
  specificWarmup,
  workSet,
  rest,
  exerciseTransition,
  done,
}

enum Side { left, right }

class WorkoutSessionState {
  final WorkoutPhase phase;
  final TrainingType trainingType;
  final List<Exercise> exercises;
  final int exerciseIndex;
  final int setIndex;
  final Side? currentSide;
  final int specificWarmupStep;
  final List<ExerciseLog> logs;
  final int elapsedSeconds;

  const WorkoutSessionState({
    required this.phase,
    required this.trainingType,
    required this.exercises,
    this.exerciseIndex = 0,
    this.setIndex = 0,
    this.currentSide,
    this.specificWarmupStep = 0,
    this.logs = const [],
    this.elapsedSeconds = 0,
  });

  Exercise get currentExercise => exercises[exerciseIndex];
  bool get isLastExercise => exerciseIndex == exercises.length - 1;
  bool get isLastSet => setIndex == currentExercise.workSets - 1;

  WorkoutSessionState copyWith({
    WorkoutPhase? phase,
    int? exerciseIndex,
    int? setIndex,
    Side? currentSide,
    bool clearSide = false,
    int? specificWarmupStep,
    List<ExerciseLog>? logs,
    int? elapsedSeconds,
  }) {
    return WorkoutSessionState(
      phase: phase ?? this.phase,
      trainingType: trainingType,
      exercises: exercises,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      setIndex: setIndex ?? this.setIndex,
      currentSide: clearSide ? null : (currentSide ?? this.currentSide),
      specificWarmupStep: specificWarmupStep ?? this.specificWarmupStep,
      logs: logs ?? this.logs,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

class WorkoutSessionNotifier extends StateNotifier<WorkoutSessionState?> {
  final Ref _ref;
  WorkoutSessionNotifier(this._ref) : super(null);

  void startWorkout(TrainingType type) {
    state = WorkoutSessionState(
      phase: WorkoutPhase.generalWarmup,
      trainingType: type,
      exercises: ExercisesData.forType(type),
    );
  }

  void onGeneralWarmupComplete() {
    state = state!.copyWith(phase: WorkoutPhase.specificWarmup);
  }

  void onSpecificWarmupStepComplete() {
    final s = state!;
    final totalSteps = s.currentExercise.hasSpecificWarmup ? 5 : 0;
    if (s.specificWarmupStep < totalSteps - 1) {
      state = s.copyWith(specificWarmupStep: s.specificWarmupStep + 1);
    } else {
      state = s.copyWith(
        phase: WorkoutPhase.workSet,
        setIndex: 0,
        currentSide: s.currentExercise.isBilateral ? Side.left : null,
      );
    }
  }

  void onWorkSetStarted() {
    state = state!.copyWith(phase: WorkoutPhase.rest);
  }

  void onRestComplete({
    required int reps,
    required double weightKg,
    required EffortLevel effort,
    required int restDurationSeconds,
  }) {
    final s = state!;
    final exercise = s.currentExercise;

    final newSet = WorkoutSet(
      setIndex: s.setIndex,
      reps: reps,
      weightKg: weightKg,
      durationSeconds: exercise.isTimeBased ? restDurationSeconds : 0,
      effort: effort,
    );

    final updatedLogs = _addSetToLogs(s.logs, exercise.id, newSet);

    // Bilateral: left done → do right side
    if (exercise.isBilateral && s.currentSide == Side.left) {
      state = s.copyWith(
        phase: WorkoutPhase.workSet,
        currentSide: Side.right,
        logs: updatedLogs,
      );
      return;
    }

    // Last set of last exercise → done
    if (s.isLastExercise && (s.isLastSet || exercise.isBilateral)) {
      _finishSession(s.copyWith(logs: updatedLogs));
      return;
    }

    // Last set of current exercise → exercise transition
    if (s.isLastSet || exercise.isBilateral) {
      state = s.copyWith(
        phase: WorkoutPhase.exerciseTransition,
        exerciseIndex: s.exerciseIndex + 1,
        setIndex: 0,
        clearSide: true,
        logs: updatedLogs,
      );
      return;
    }

    // More sets in current exercise
    state = s.copyWith(
      phase: WorkoutPhase.workSet,
      setIndex: s.setIndex + 1,
      clearSide: true,
      logs: updatedLogs,
    );
  }

  void onExerciseTransitionComplete() {
    final s = state!;
    state = s.copyWith(
      phase: WorkoutPhase.workSet,
      currentSide: s.currentExercise.isBilateral ? Side.left : null,
    );
  }

  void tickElapsed() {
    if (state != null) {
      state = state!.copyWith(elapsedSeconds: state!.elapsedSeconds + 1);
    }
  }

  Future<void> _finishSession(WorkoutSessionState s) async {
    state = s.copyWith(phase: WorkoutPhase.done);
    final session = WorkoutSession(
      id: const Uuid().v4(),
      type: s.trainingType,
      date: DateTime.now(),
      totalDurationSeconds: s.elapsedSeconds,
      exerciseLogs: s.logs,
    );
    await SaveWorkoutSession(_ref.read(workoutRepositoryProvider)).execute(session);
    _ref.invalidate(trainingHistoryProvider);
  }

  List<ExerciseLog> _addSetToLogs(
      List<ExerciseLog> logs, String exerciseId, WorkoutSet newSet) {
    final existing = logs.indexWhere((l) => l.exerciseId == exerciseId);
    if (existing == -1) {
      return [...logs, ExerciseLog(exerciseId: exerciseId, sets: [newSet])];
    }
    final updated = List<ExerciseLog>.from(logs);
    final oldLog = updated[existing];
    updated[existing] = ExerciseLog(
      exerciseId: exerciseId,
      sets: [...oldLog.sets, newSet],
    );
    return updated;
  }
}

final workoutSessionProvider =
    StateNotifierProvider<WorkoutSessionNotifier, WorkoutSessionState?>((ref) {
  return WorkoutSessionNotifier(ref);
});
```

- [ ] **Step 6: Verify it compiles**

```bash
flutter build apk --debug 2>&1 | tail -5
```

Expected: no compile errors.

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/providers/ lib/core/services/
git commit -m "feat: add Riverpod providers and workout session state machine"
```

---

## Task 12: Shared widgets

**Files:**
- Create: `lib/presentation/widgets/ring_timer_widget.dart`
- Create: `lib/presentation/widgets/scroll_picker_widget.dart`
- Create: `lib/presentation/widgets/effort_marker_widget.dart`

- [ ] **Step 1: Create ring_timer_widget.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class RingTimerWidget extends StatelessWidget {
  final double progress; // 1.0 = full, 0.0 = empty
  final int remainingSeconds;
  final double size;

  const RingTimerWidget({
    required this.progress,
    required this.remainingSeconds,
    this.size = 220,
    super.key,
  });

  String get _timeLabel {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(progress: progress),
          ),
          Text(_timeLabel, style: AppTypography.displayLarge),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 6.0;

    final bgPaint = Paint()
      ..color = AppColors.timerRingBackground
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fgPaint = Paint()
      ..color = AppColors.timerRingActive
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
```

- [ ] **Step 2: Create scroll_picker_widget.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ScrollPickerWidget extends StatefulWidget {
  final List<String> items;
  final int initialIndex;
  final ValueChanged<int> onChanged;
  final String label;

  const ScrollPickerWidget({
    required this.items,
    required this.initialIndex,
    required this.onChanged,
    required this.label,
    super.key,
  });

  @override
  State<ScrollPickerWidget> createState() => _ScrollPickerWidgetState();
}

class _ScrollPickerWidgetState extends State<ScrollPickerWidget> {
  late final FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: AppTypography.label),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          width: 80,
          child: ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: 40,
            perspective: 0.003,
            diameterRatio: 1.5,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: widget.onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.items.length,
              builder: (context, index) => Center(
                child: Text(
                  widget.items[index],
                  style: AppTypography.headingMedium.copyWith(
                    color: _controller.hasClients &&
                            _controller.selectedItem == index
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Convenience: reps picker (0..30)
List<String> repsItems() => List.generate(31, (i) => '$i');

// Convenience: weight picker (0, 20, 22.5, 25, ..., 250) in 2.5kg steps
List<String> weightItems() {
  final weights = [0.0, 20.0];
  double w = 22.5;
  while (w <= 250) {
    weights.add(w);
    w += 2.5;
  }
  return weights.map((w) => w == 0.0 ? 'BK' : (w % 1 == 0 ? '${w.toInt()}' : '$w')).toList();
}

double weightFromIndex(int index) {
  if (index == 0) return 0.0;
  if (index == 1) return 20.0;
  return 22.5 + (index - 2) * 2.5;
}

int indexFromWeight(double kg) {
  if (kg == 0) return 0;
  if (kg == 20) return 1;
  return ((kg - 22.5) / 2.5 + 2).round().clamp(0, weightItems().length - 1);
}
```

- [ ] **Step 3: Create effort_marker_widget.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/effort_level.dart';

class EffortMarkerWidget extends StatelessWidget {
  final EffortLevel selected;
  final ValueChanged<EffortLevel> onChanged;

  const EffortMarkerWidget({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: EffortLevel.values.map((level) {
        final isSelected = selected == level;
        return GestureDetector(
          onTap: () => onChanged(level),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.surface : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.effortGold : AppColors.textSecondary,
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              level.label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.effortGold : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/widgets/
git commit -m "feat: add shared widgets (ring timer, scroll picker, effort marker)"
```

---

## Task 13: Home screen

**Files:**
- Modify: `lib/presentation/pages/home/home_page.dart`

- [ ] **Step 1: Implement home_page.dart**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/routes/app_router.gr.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/training_type.dart';
import '../../../domain/entities/workout_session.dart';
import '../../../domain/usecases/should_show_monthly_progress.dart';
import '../../providers/training_history_provider.dart';
import '../../providers/workout_repository_provider.dart';

@RoutePage()
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  TrainingType _nextTrainingType(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) return TrainingType.a;
    final sorted = [...sessions]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.first.type == TrainingType.a ? TrainingType.b : TrainingType.a;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(trainingHistoryProvider);

    return historyAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (sessions) {
        final sorted = [...sessions]..sort((a, b) => b.date.compareTo(a.date));
        final next = _nextTrainingType(sessions);
        final recent = sorted.take(3).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent sessions
                  if (recent.isNotEmpty) ...[
                    Text('Zuletzt', style: AppTypography.label),
                    const SizedBox(height: 12),
                    ...recent.map((s) => _RecentSessionRow(session: s)),
                    const SizedBox(height: 48),
                  ],

                  // Next training
                  Text('Nächstes Training', style: AppTypography.label),
                  const SizedBox(height: 16),
                  Text('Training ${next.label}', style: AppTypography.headingLarge),
                  const Spacer(),

                  // Start button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final repo = ref.read(workoutRepositoryProvider);
                        final showProgress =
                            await ShouldShowMonthlyProgress(repo).execute();
                        if (context.mounted && showProgress) {
                          await context.router.push(const MonthlyProgressRoute());
                        }
                        if (context.mounted) {
                          context.router.push(WorkoutRoute(trainingType: next));
                        }
                      },
                      child: Text('Training starten',
                          style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecentSessionRow extends StatelessWidget {
  final WorkoutSession session;
  const _RecentSessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            DateFormat('dd.MM.yy').format(session.date),
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Text(
            'Training ${session.type.label}',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text('✓',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
```

Note: Add `intl: ^0.20.2` to pubspec.yaml if not already present, then run `flutter pub get`.

- [ ] **Step 2: Run on simulator and verify home screen**

```bash
flutter run
```

Expected: Black screen, "Training A" or "B" label, recent sessions list, "Training starten" button.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/pages/home/
git commit -m "feat: implement home screen with session history and next training"
```

---

## Task 14: General warmup widget

**Files:**
- Create: `lib/presentation/pages/workout/widgets/general_warmup_widget.dart`

- [ ] **Step 1: Implement general_warmup_widget.dart**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/timer_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../providers/workout_session_provider.dart';
import '../../../widgets/ring_timer_widget.dart';

class GeneralWarmupWidget extends ConsumerStatefulWidget {
  const GeneralWarmupWidget({super.key});

  @override
  ConsumerState<GeneralWarmupWidget> createState() => _GeneralWarmupWidgetState();
}

class _GeneralWarmupWidgetState extends ConsumerState<GeneralWarmupWidget> {
  static const _totalRounds = TimerConstants.generalWarmupRounds;
  static const _workSeconds = TimerConstants.generalWarmupWorkSeconds;
  static const _restSeconds = TimerConstants.generalWarmupRestSeconds;

  int _round = 1;
  bool _isWork = true;
  int _remaining = _workSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTick();
  }

  void _startTick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          if (_isWork) {
            if (_round == _totalRounds) {
              _timer?.cancel();
              ref.read(workoutSessionProvider.notifier).onGeneralWarmupComplete();
              return;
            }
            _isWork = false;
            _remaining = _restSeconds;
          } else {
            _round++;
            _isWork = true;
            _remaining = _workSeconds;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _isWork ? _workSeconds : _restSeconds;
    final progress = _remaining / total;
    final label = _isWork ? 'Runde $_round / $_totalRounds' : 'Wechsel';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Allgemeines Aufwärmen', style: AppTypography.label),
        const SizedBox(height: 8),
        Text(label, style: AppTypography.headingMedium),
        const SizedBox(height: 40),
        RingTimerWidget(progress: progress, remainingSeconds: _remaining),
        const SizedBox(height: 24),
        Text(
          _isWork ? 'AMRAP – Kniebeugen / Liegestütze / Jumping Jacks' : 'Position wechseln',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/pages/workout/widgets/general_warmup_widget.dart
git commit -m "feat: add general warmup widget with 5x30s timer"
```

---

## Task 15: Specific warmup widget

**Files:**
- Create: `lib/presentation/pages/workout/widgets/specific_warmup_widget.dart`

- [ ] **Step 1: Implement specific_warmup_widget.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/timer_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/warmup_calculator.dart';
import '../../../../domain/entities/training_type.dart';
import '../../../providers/rest_timer_provider.dart';
import '../../../providers/training_history_provider.dart';
import '../../../providers/workout_session_provider.dart';
import '../../../widgets/ring_timer_widget.dart';

class SpecificWarmupWidget extends ConsumerWidget {
  const SpecificWarmupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionProvider)!;
    final exercise = session.currentExercise;
    final lastSessionAsync = ref.watch(lastSessionForTypeProvider(session.trainingType));

    return lastSessionAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (lastSession) {
        final lastWeight = lastSession?.logFor(exercise.id)?.bestWeightKg ?? 20.0;
        final steps = calculateWarmupSteps(lastWeight);
        final stepIndex = session.specificWarmupStep;
        final step = steps[stepIndex.clamp(0, steps.length - 1)];
        final isLastStep = stepIndex >= steps.length - 1;

        return _SpecificWarmupContent(
          step: step,
          stepIndex: stepIndex,
          totalSteps: steps.length,
          isLastStep: isLastStep,
        );
      },
    );
  }
}

class _SpecificWarmupContent extends ConsumerStatefulWidget {
  final WarmupStep step;
  final int stepIndex;
  final int totalSteps;
  final bool isLastStep;

  const _SpecificWarmupContent({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.isLastStep,
  });

  @override
  ConsumerState<_SpecificWarmupContent> createState() => _SpecificWarmupContentState();
}

class _SpecificWarmupContentState extends ConsumerState<_SpecificWarmupContent> {
  bool _showTimer = false;

  void _onSetDone() {
    setState(() => _showTimer = true);
    ref.read(restTimerProvider.notifier).start(
      TimerConstants.specificWarmupRestSeconds,
      onComplete: () {
        if (mounted) {
          setState(() => _showTimer = false);
          ref.read(workoutSessionProvider.notifier).onSpecificWarmupStepComplete();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(restTimerProvider);

    if (_showTimer) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Pause', style: AppTypography.label),
          const SizedBox(height: 40),
          RingTimerWidget(
            progress: timer.progress,
            remainingSeconds: timer.remainingSeconds,
          ),
        ],
      );
    }

    final weightStr = widget.step.weightKg == 20
        ? 'Stange (20 kg)'
        : '${widget.step.weightKg % 1 == 0 ? widget.step.weightKg.toInt() : widget.step.weightKg} kg';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Spezifisches Aufwärmen', style: AppTypography.label),
        const SizedBox(height: 4),
        Text('${widget.stepIndex + 1} / ${widget.totalSteps}',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 40),
        Text(widget.step.label, style: AppTypography.headingMedium),
        const SizedBox(height: 8),
        Text(weightStr, style: AppTypography.headingLarge),
        const SizedBox(height: 4),
        Text('${widget.step.repsLabel} Wdh',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 64),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _onSetDone,
            child: Text(widget.isLastStep ? 'Fertig → Arbeitssätze' : 'Satz geschafft',
                style: AppTypography.bodyLarge),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/pages/workout/widgets/specific_warmup_widget.dart
git commit -m "feat: add specific warmup widget with percentage-based sets"
```

---

## Task 16: Set screen + rest screen widgets

**Files:**
- Create: `lib/presentation/pages/workout/widgets/set_screen_widget.dart`
- Create: `lib/presentation/pages/workout/widgets/rest_screen_widget.dart`

- [ ] **Step 1: Create set_screen_widget.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/exercise.dart';
import '../../../../domain/entities/workout_session.dart';
import '../../../providers/training_history_provider.dart';
import '../../../providers/workout_session_provider.dart';

class SetScreenWidget extends ConsumerWidget {
  const SetScreenWidget({super.key});

  String _sideLabel(Side? side) => switch (side) {
        Side.left => ' – Links',
        Side.right => ' – Rechts',
        null => '',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(workoutSessionProvider)!;
    final exercise = session.currentExercise;
    final lastSessionAsync =
        ref.watch(lastSessionForTypeProvider(session.trainingType));
    final elapsedSeconds = session.elapsedSeconds;

    final setLabel = exercise.workSets > 1
        ? 'Satz ${session.setIndex + 1} von ${exercise.workSets}'
        : '';

    final rangeLabel = exercise.isTimeBased
        ? '60 Sekunden'
        : 'Ziel: ${exercise.repMin}–${exercise.repMax} Wdh';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Training duration top right
              Align(
                alignment: Alignment.topRight,
                child: Text(_formatDuration(elapsedSeconds),
                    style: AppTypography.label),
              ),
              const SizedBox(height: 40),

              Text(exercise.name + _sideLabel(session.currentSide),
                  style: AppTypography.headingLarge),
              const SizedBox(height: 4),
              if (setLabel.isNotEmpty)
                Text(setLabel,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text(rangeLabel,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),

              // Last result
              lastSessionAsync.whenOrNull(
                    data: (last) {
                      final log = last?.logFor(exercise.id);
                      if (log == null || log.sets.isEmpty) return null;
                      final setIdx = session.setIndex.clamp(0, log.sets.length - 1);
                      final s = log.sets[setIdx];
                      return Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Text(
                          'Letztes Mal: ${s.displayLabel}',
                          style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      );
                    },
                  ) ??
                  const SizedBox.shrink(),

              const Spacer(),

              // Big start button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () =>
                      ref.read(workoutSessionProvider.notifier).onWorkSetStarted(),
                  child: Text('Satz starten',
                      style: AppTypography.headingMedium
                          .copyWith(color: AppColors.background)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 2: Create rest_screen_widget.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/timer_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/effort_level.dart';
import '../../../providers/rest_timer_provider.dart';
import '../../../providers/training_history_provider.dart';
import '../../../providers/workout_session_provider.dart';
import '../../../widgets/effort_marker_widget.dart';
import '../../../widgets/ring_timer_widget.dart';
import '../../../widgets/scroll_picker_widget.dart';

class RestScreenWidget extends ConsumerStatefulWidget {
  const RestScreenWidget({super.key});

  @override
  ConsumerState<RestScreenWidget> createState() => _RestScreenWidgetState();
}

class _RestScreenWidgetState extends ConsumerState<RestScreenWidget> {
  int _selectedRepsIndex = 0;
  int _selectedWeightIndex = 1; // default to 20kg (bar)
  EffortLevel _effort = EffortLevel.none;
  bool _timerStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAndStart());
  }

  void _initAndStart() {
    final session = ref.read(workoutSessionProvider)!;
    final exercise = session.currentExercise;

    // Pre-fill pickers with last session values
    final lastSessionAsync = ref.read(lastSessionForTypeProvider(session.trainingType));
    lastSessionAsync.whenData((lastSession) {
      final log = lastSession?.logFor(exercise.id);
      if (log != null && log.sets.isNotEmpty) {
        final setIdx = session.setIndex.clamp(0, log.sets.length - 1);
        final lastSet = log.sets[setIdx];
        setState(() {
          _selectedRepsIndex = lastSet.reps.clamp(0, 30);
          _selectedWeightIndex = indexFromWeight(lastSet.weightKg);
        });
      }
    });

    final restDuration = exercise.isBilateral && session.currentSide == Side.right
        ? TimerConstants.bilateralRestSeconds
        : exercise.isBilateral
            ? TimerConstants.bilateralRestSeconds
            : TimerConstants.workSetRestSeconds;

    setState(() => _timerStarted = true);
    ref.read(restTimerProvider.notifier).start(restDuration, onComplete: _onTimerComplete);
  }

  void _onTimerComplete() {
    if (!mounted) return;
    final session = ref.read(workoutSessionProvider)!;
    final exercise = session.currentExercise;
    final weight = weightFromIndex(_selectedWeightIndex);

    ref.read(workoutSessionProvider.notifier).onRestComplete(
          reps: exercise.isTimeBased ? 0 : _selectedRepsIndex,
          weightKg: weight,
          effort: _effort,
          restDurationSeconds: exercise.isTimeBased
              ? TimerConstants.farmerWalkDurationSeconds
              : 0,
        );
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(restTimerProvider);
    final session = ref.watch(workoutSessionProvider)!;
    final exercise = session.currentExercise;
    final lastSessionAsync = ref.watch(lastSessionForTypeProvider(session.trainingType));
    final elapsedSeconds = session.elapsedSeconds;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Top row: to-beat + duration
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  lastSessionAsync.whenOrNull(
                        data: (last) {
                          final log = last?.logFor(exercise.id);
                          if (log == null || log.sets.isEmpty) return null;
                          final setIdx = session.setIndex.clamp(0, log.sets.length - 1);
                          return Text(
                            'Zu schlagen: ${log.sets[setIdx].displayLabel}',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.textSecondary),
                          );
                        },
                      ) ??
                      const SizedBox.shrink(),
                  Text(_formatDuration(elapsedSeconds), style: AppTypography.label),
                ],
              ),

              const Spacer(),

              // Ring timer
              RingTimerWidget(
                progress: timer.progress,
                remainingSeconds: timer.remainingSeconds,
                size: 240,
              ),

              const SizedBox(height: 32),

              // Effort marker
              EffortMarkerWidget(
                selected: _effort,
                onChanged: (e) => setState(() => _effort = e),
              ),

              const SizedBox(height: 32),

              // Pickers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!exercise.isTimeBased)
                    ScrollPickerWidget(
                      label: 'WDH',
                      items: repsItems(),
                      initialIndex: _selectedRepsIndex,
                      onChanged: (i) => setState(() => _selectedRepsIndex = i),
                    )
                  else
                    Text('60s', style: AppTypography.headingLarge),
                  ScrollPickerWidget(
                    label: 'KG',
                    items: weightItems(),
                    initialIndex: _selectedWeightIndex,
                    onChanged: (i) => setState(() => _selectedWeightIndex = i),
                  ),
                ],
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/pages/workout/widgets/
git commit -m "feat: add set screen and rest screen widgets"
```

---

## Task 17: Exercise transition + workout page orchestrator

**Files:**
- Create: `lib/presentation/pages/workout/widgets/exercise_transition_widget.dart`
- Modify: `lib/presentation/pages/workout/view/workout_page.dart`

- [ ] **Step 1: Create exercise_transition_widget.dart**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/timer_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../providers/training_history_provider.dart';
import '../../../providers/workout_session_provider.dart';
import '../../../widgets/ring_timer_widget.dart';

class ExerciseTransitionWidget extends ConsumerStatefulWidget {
  const ExerciseTransitionWidget({super.key});

  @override
  ConsumerState<ExerciseTransitionWidget> createState() =>
      _ExerciseTransitionWidgetState();
}

class _ExerciseTransitionWidgetState
    extends ConsumerState<ExerciseTransitionWidget> {
  int _remaining = TimerConstants.exerciseTransitionSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          _timer?.cancel();
          ref.read(workoutSessionProvider.notifier).onExerciseTransitionComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _skip() {
    _timer?.cancel();
    ref.read(workoutSessionProvider.notifier).onExerciseTransitionComplete();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(workoutSessionProvider)!;
    final exercise = session.currentExercise;
    final lastSessionAsync =
        ref.watch(lastSessionForTypeProvider(session.trainingType));
    final progress =
        _remaining / TimerConstants.exerciseTransitionSeconds;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Als nächstes', style: AppTypography.label),
              const SizedBox(height: 8),
              Text(exercise.name, style: AppTypography.headingLarge),
              const SizedBox(height: 8),
              lastSessionAsync.whenOrNull(
                    data: (last) {
                      final log = last?.logFor(exercise.id);
                      if (log == null || log.sets.isEmpty) return null;
                      return Text(
                        'Letztes Mal: ${log.sets.first.displayLabel}',
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      );
                    },
                  ) ??
                  const SizedBox.shrink(),
              const SizedBox(height: 48),
              RingTimerWidget(
                  progress: progress, remainingSeconds: _remaining, size: 180),
              const SizedBox(height: 32),
              TextButton(
                onPressed: _skip,
                child: Text('Überspringen →',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Implement workout_page.dart orchestrator**

```dart
import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/routes/app_router.gr.dart';
import '../../../../domain/entities/training_type.dart';
import '../../../providers/workout_session_provider.dart';
import '../widgets/exercise_transition_widget.dart';
import '../widgets/general_warmup_widget.dart';
import '../widgets/rest_screen_widget.dart';
import '../widgets/set_screen_widget.dart';
import '../widgets/specific_warmup_widget.dart';

@RoutePage()
class WorkoutPage extends ConsumerStatefulWidget {
  final TrainingType trainingType;
  const WorkoutPage({required this.trainingType, super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutSessionProvider.notifier).startWorkout(widget.trainingType);
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        ref.read(workoutSessionProvider.notifier).tickElapsed();
      });
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(workoutSessionProvider);
    if (session == null) return const SizedBox.shrink();

    if (session.phase == WorkoutPhase.done) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _durationTimer?.cancel();
        context.router.replace(SummaryRoute(session: session));
      });
      return const SizedBox.shrink();
    }

    return switch (session.phase) {
      WorkoutPhase.generalWarmup => const GeneralWarmupWidget(),
      WorkoutPhase.specificWarmup => const SpecificWarmupWidget(),
      WorkoutPhase.workSet => const SetScreenWidget(),
      WorkoutPhase.rest => const RestScreenWidget(),
      WorkoutPhase.exerciseTransition => const ExerciseTransitionWidget(),
      WorkoutPhase.done => const SizedBox.shrink(),
    };
  }
}
```

Note: `SummaryRoute` needs a `session` parameter — update the route in the next task.

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/pages/workout/
git commit -m "feat: add exercise transition and workout page orchestrator"
```

---

## Task 18: Summary screen

**Files:**
- Modify: `lib/presentation/pages/summary/summary_page.dart`
- Modify: `lib/core/routes/app_router.dart` (add session param)

- [ ] **Step 1: Add session param to SummaryRoute in app_router.dart**

```dart
AutoRoute(page: SummaryRoute.page),
```

The `SummaryPage` will receive `WorkoutSessionState` as a parameter.

- [ ] **Step 2: Implement summary_page.dart**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../../core/routes/app_router.gr.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/training_type.dart';
import '../../providers/workout_session_provider.dart';

@RoutePage()
class SummaryPage extends StatelessWidget {
  final WorkoutSessionState session;
  const SummaryPage({required this.session, super.key});

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}min';
    return '${m}min ${s.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Training ${session.trainingType.label} abgeschlossen',
                  style: AppTypography.headingLarge),
              const SizedBox(height: 4),
              Text(_formatDuration(session.elapsedSeconds),
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 40),
              Text('Heute', style: AppTypography.label),
              const SizedBox(height: 12),
              ...session.logs.expand((log) {
                final exerciseName = session.exercises
                    .firstWhere((e) => e.id == log.exerciseId,
                        orElse: () => session.exercises.first)
                    .name;
                return [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exerciseName, style: AppTypography.bodyLarge),
                        const SizedBox(height: 4),
                        ...log.sets.map((s) => Text(
                              s.displayLabel,
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textSecondary),
                            )),
                      ],
                    ),
                  ),
                ];
              }),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => context.router.replaceAll([const HomeRoute()]),
                  child: Text('Fertig',
                      style: AppTypography.bodyLarge
                          .copyWith(color: AppColors.background, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Rebuild routes**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/pages/summary/ lib/core/routes/
git commit -m "feat: implement summary screen"
```

---

## Task 19: Monthly progress screen

**Files:**
- Modify: `lib/presentation/pages/monthly_progress/monthly_progress_page.dart`

- [ ] **Step 1: Add monthly progress provider**

Add to `lib/presentation/providers/training_history_provider.dart`:

```dart
import '../../domain/usecases/get_monthly_progress.dart';

final monthlyProgressProvider = FutureProvider.autoDispose<Map<String, double>?>((ref) async {
  final repo = ref.read(workoutRepositoryProvider);
  return GetMonthlyProgress(repo).execute();
});
```

- [ ] **Step 2: Implement monthly_progress_page.dart**

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/exercises_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/training_history_provider.dart';

@RoutePage()
class MonthlyProgressPage extends ConsumerWidget {
  const MonthlyProgressPage({super.key});

  String _formatPercent(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${(value * 100).toStringAsFixed(1)}%';
  }

  Color _colorFor(double value) {
    if (value > 0) return AppColors.textPrimary;
    if (value < 0) return AppColors.textSecondary;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(monthlyProgressProvider);
    final allExercises = [...ExercisesData.trainingA, ...ExercisesData.trainingB];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: progressAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (progress) {
              if (progress == null) {
                return const Center(child: Text('Nicht genug Daten'));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Letzter Monat', style: AppTypography.label),
                  const SizedBox(height: 8),
                  Text('Progression', style: AppTypography.headingLarge),
                  const SizedBox(height: 40),
                  ...allExercises
                      .where((e) => progress.containsKey(e.id))
                      .map((exercise) {
                    final pct = progress[exercise.id]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(exercise.name, style: AppTypography.bodyLarge),
                          ),
                          Text(
                            _formatPercent(pct),
                            style: AppTypography.bodyLarge
                                .copyWith(color: _colorFor(pct), fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.router.pop(),
                      child: Text('Weiter zum Training', style: AppTypography.bodyLarge),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/pages/monthly_progress/ lib/presentation/providers/
git commit -m "feat: implement monthly progress screen"
```

---

## Task 20: End-to-end simulator test + fixes

- [ ] **Step 1: Run full app on simulator**

```bash
flutter run
```

- [ ] **Step 2: Walk through the complete flow**

Test checklist:
- [ ] Home screen shows "Training B" (seed A was last)
- [ ] Tap "Training starten" → general warmup starts, 5×30s timer runs
- [ ] Timer advances to specific warmup → shows bar (20kg), then percentage sets
- [ ] Work set screen shows exercise name + last session data
- [ ] "Satz starten" → rest screen appears with ring timer
- [ ] Scroll picker works left (reps) and right (weight)
- [ ] Effort marker toggles –, *, **
- [ ] Timer counts down, frosch-klicker plays at 10s (if audio files present)
- [ ] Timer reaches 0, auto-advances to next set or exercise transition
- [ ] Bulgarian Split Squat: shows "Links" then "Rechts"
- [ ] Farmer Walk: shows 60s, no reps picker
- [ ] Summary screen shows all sets with display labels
- [ ] "Fertig" returns to home, home now shows "Training A" as next

- [ ] **Step 3: Fix any issues found during testing**

Common issues to watch for:
- Route parameter type mismatch (SummaryRoute expecting WorkoutSessionState)
- Null state on WorkoutPage before initState fires
- Timer not cancelling on widget disposal
- Scroll picker initial position not centering correctly

- [ ] **Step 4: Add `intl` dependency if DateFormat causes issues**

```yaml
# in pubspec.yaml under dependencies:
intl: ^0.20.2
```

```bash
flutter pub get
```

- [ ] **Step 5: Final commit**

```bash
git add -A
git commit -m "feat: complete MVP — dad strong training app"
```

---

## Self-Review Checklist

**Spec coverage:**
- [x] Training A exercises hardcoded
- [x] Training B exercises hardcoded
- [x] General warmup 5×30s + 5s rest
- [x] Specific warmup with percentage calculation
- [x] Work sets with set screen
- [x] Rest timer 3min with ring + scroll pickers + effort marker
- [x] Auto-log on timer completion
- [x] Bilateral exercise flow (left → 1min → right)
- [x] Farmer Walk 60s timed
- [x] Exercise transition 2min, skippable
- [x] Summary screen with all sets
- [x] Home screen with A/B alternation
- [x] Monthly progress screen
- [x] Should-show logic (first day of month, ≥2 sessions previous month)
- [x] Seed data from whiteboard
- [x] Frosch-klicker at 10s, beep at 0
- [x] Training duration counter top-right
- [x] Effort marker –/*/**
- [x] Dark theme, Inter font

**Not in scope (confirmed):**
- No automatic weight increase
- No charts
- No settings
- No accounts
- No push notifications
