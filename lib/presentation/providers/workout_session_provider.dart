import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/exercises_data.dart';
import '../../core/constants/timer_constants.dart';
import '../../core/utils/progression_calculator.dart';
import '../../domain/entities/effort_level.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/training_type.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/workout_set.dart';
import 'rest_timer_provider.dart';

enum WorkoutPhase {
  generalWarmup,
  specificWarmup,
  preSetAdvice,   // show last weight + progression recommendation
  activeSet,      // user performs set — only a "Done" button
  resting,        // 3-min rest — user enters reps/weight/effort here
  bilateralResting, // 1-min rest between sides
  exerciseTransition,
  complete,
}

class WorkoutSessionState {
  final WorkoutPhase phase;
  final TrainingType trainingType;
  final List<Exercise> exercises;
  final int exerciseIndex;
  final int setIndex;
  final bool isFirstSide;
  final int selectedReps;
  final double selectedWeight;
  final EffortLevel selectedEffort;
  final List<WorkoutSet> currentExerciseSets;
  final List<ExerciseLog> completedLogs;
  final DateTime startTime;
  final Map<String, ProgressionAdvice> progressionAdvice;

  const WorkoutSessionState({
    required this.phase,
    required this.trainingType,
    required this.exercises,
    required this.exerciseIndex,
    required this.setIndex,
    required this.isFirstSide,
    required this.selectedReps,
    required this.selectedWeight,
    required this.selectedEffort,
    required this.currentExerciseSets,
    required this.completedLogs,
    required this.startTime,
    required this.progressionAdvice,
  });

  Exercise get currentExercise => exercises[exerciseIndex];
  bool get isLastExercise => exerciseIndex == exercises.length - 1;
  ProgressionAdvice? get currentAdvice =>
      progressionAdvice[currentExercise.id];

  WorkoutSessionState copyWith({
    WorkoutPhase? phase,
    int? exerciseIndex,
    int? setIndex,
    bool? isFirstSide,
    int? selectedReps,
    double? selectedWeight,
    EffortLevel? selectedEffort,
    List<WorkoutSet>? currentExerciseSets,
    List<ExerciseLog>? completedLogs,
  }) {
    return WorkoutSessionState(
      phase: phase ?? this.phase,
      trainingType: trainingType,
      exercises: exercises,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      setIndex: setIndex ?? this.setIndex,
      isFirstSide: isFirstSide ?? this.isFirstSide,
      selectedReps: selectedReps ?? this.selectedReps,
      selectedWeight: selectedWeight ?? this.selectedWeight,
      selectedEffort: selectedEffort ?? this.selectedEffort,
      currentExerciseSets: currentExerciseSets ?? this.currentExerciseSets,
      completedLogs: completedLogs ?? this.completedLogs,
      startTime: startTime,
      progressionAdvice: progressionAdvice,
    );
  }
}

class WorkoutSessionNotifier extends StateNotifier<WorkoutSessionState> {
  final Ref _ref;

  WorkoutSessionNotifier(this._ref)
      : super(WorkoutSessionState(
          phase: WorkoutPhase.generalWarmup,
          trainingType: TrainingType.a,
          exercises: ExercisesData.trainingA,
          exerciseIndex: 0,
          setIndex: 0,
          isFirstSide: true,
          selectedReps: 0,
          selectedWeight: 20,
          selectedEffort: EffortLevel.none,
          currentExerciseSets: [],
          completedLogs: [],
          startTime: DateTime.now(),
          progressionAdvice: {},
        ));

  void startSession(TrainingType type, {WorkoutSession? lastSession}) {
    final exercises = ExercisesData.forType(type);

    // Pre-compute progression advice for all exercises
    final advice = <String, ProgressionAdvice>{};
    for (final ex in exercises) {
      final lastLog = lastSession?.logFor(ex.id);
      advice[ex.id] = calculateProgression(ex, lastLog);
    }

    final firstEx = exercises[0];
    final firstAdvice = advice[firstEx.id]!;

    state = WorkoutSessionState(
      phase: WorkoutPhase.generalWarmup,
      trainingType: type,
      exercises: exercises,
      exerciseIndex: 0,
      setIndex: 0,
      isFirstSide: true,
      selectedReps: firstAdvice.lastBestReps > 0
          ? firstAdvice.lastBestReps
          : firstEx.repMin,
      selectedWeight: firstAdvice.recommendedWeight,
      selectedEffort: EffortLevel.none,
      currentExerciseSets: [],
      completedLogs: [],
      startTime: DateTime.now(),
      progressionAdvice: advice,
    );
  }

  void completeGeneralWarmup() {
    final ex = state.currentExercise;
    if (ex.hasSpecificWarmup) {
      state = state.copyWith(phase: WorkoutPhase.specificWarmup);
    } else {
      state = state.copyWith(phase: WorkoutPhase.preSetAdvice);
    }
  }

  void completeSpecificWarmup() {
    state = state.copyWith(phase: WorkoutPhase.preSetAdvice);
  }

  // User confirmed advice screen → start set
  void advanceFromAdvice() {
    state = state.copyWith(phase: WorkoutPhase.activeSet);
  }

  void updateReps(int reps) => state = state.copyWith(selectedReps: reps);
  void updateWeight(double weight) =>
      state = state.copyWith(selectedWeight: weight);
  void updateEffort(EffortLevel effort) =>
      state = state.copyWith(selectedEffort: effort);

  // Temporary: skip rest for testing — REMOVE before release
  void skipRest() {
    _ref.read(restTimerProvider.notifier).cancel();
    if (state.phase == WorkoutPhase.bilateralResting) {
      _onBilateralRestComplete();
    } else {
      _onRestComplete();
    }
  }

  // Called from activeSet when user taps "Fertig → Pause starten"
  void startRest() {
    final ex = state.currentExercise;
    final isBilateralFirst = ex.isBilateral && state.isFirstSide;

    if (isBilateralFirst) {
      state = state.copyWith(phase: WorkoutPhase.bilateralResting);
      _ref.read(restTimerProvider.notifier).start(
            TimerConstants.bilateralRestSeconds,
            onComplete: _onBilateralRestComplete,
          );
    } else {
      state = state.copyWith(phase: WorkoutPhase.resting);
      _ref.read(restTimerProvider.notifier).start(
            TimerConstants.workSetRestSeconds,
            onComplete: _onRestComplete,
          );
    }
  }

  // Bilateral rest ends → move to second side (skip advice for same exercise)
  void _onBilateralRestComplete() {
    state = state.copyWith(
      phase: WorkoutPhase.activeSet,
      isFirstSide: false,
    );
  }

  // Main rest ends → log set, advance
  void _onRestComplete() {
    final ex = state.currentExercise;

    final loggedSet = WorkoutSet(
      setIndex: state.setIndex,
      reps: ex.isTimeBased ? 0 : state.selectedReps,
      weightKg: state.selectedWeight,
      durationSeconds: ex.isTimeBased
          ? TimerConstants.farmerWalkDurationSeconds
          : 0,
      effort: state.selectedEffort,
    );
    final updatedSets = [...state.currentExerciseSets, loggedSet];

    final nextSetIndex = state.setIndex + 1;

    if (nextSetIndex < ex.workSets) {
      // More sets of same exercise — skip advice, go straight to activeSet
      state = state.copyWith(
        phase: WorkoutPhase.activeSet,
        setIndex: nextSetIndex,
        isFirstSide: true,
        currentExerciseSets: updatedSets,
        selectedEffort: EffortLevel.none,
      );
    } else {
      // Exercise complete
      final exerciseLog = ExerciseLog(
        exerciseId: ex.id,
        sets: updatedSets,
      );
      final updatedLogs = [...state.completedLogs, exerciseLog];

      if (state.isLastExercise) {
        state = state.copyWith(
          phase: WorkoutPhase.complete,
          completedLogs: updatedLogs,
          currentExerciseSets: [],
        );
      } else {
        final nextExIndex = state.exerciseIndex + 1;
        final nextEx = state.exercises[nextExIndex];
        final nextAdvice = state.progressionAdvice[nextEx.id]!;

        state = state.copyWith(
          phase: WorkoutPhase.exerciseTransition,
          exerciseIndex: nextExIndex,
          setIndex: 0,
          isFirstSide: true,
          selectedReps: nextAdvice.lastBestReps > 0
              ? nextAdvice.lastBestReps
              : nextEx.repMin,
          selectedWeight: nextAdvice.recommendedWeight,
          selectedEffort: EffortLevel.none,
          currentExerciseSets: [],
          completedLogs: updatedLogs,
        );

        _ref.read(restTimerProvider.notifier).start(
              TimerConstants.exerciseTransitionSeconds,
              onComplete: _onTransitionComplete,
            );
      }
    }
  }

  void _onTransitionComplete() {
    final ex = state.currentExercise;
    if (ex.hasSpecificWarmup) {
      state = state.copyWith(phase: WorkoutPhase.specificWarmup);
    } else {
      state = state.copyWith(phase: WorkoutPhase.preSetAdvice);
    }
  }

  void skipTransition() {
    _ref.read(restTimerProvider.notifier).cancel();
    _onTransitionComplete();
  }
}

final workoutSessionProvider =
    StateNotifierProvider<WorkoutSessionNotifier, WorkoutSessionState>((ref) {
  return WorkoutSessionNotifier(ref);
});
