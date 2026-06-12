import 'dart:async';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../models/enums.dart';
import 'database_provider.dart';
import 'timer_provider.dart';

class ActiveSet {
  final int? id; // Null if not saved to DB yet
  final double weight;
  final int reps;
  final SetType setType;
  final int restTime;
  final bool isCompleted;
  final double? lastWeight;
  final int? lastReps;

  ActiveSet({
    this.id,
    required this.weight,
    required this.reps,
    required this.setType,
    required this.restTime,
    required this.isCompleted,
    this.lastWeight,
    this.lastReps,
  });

  ActiveSet copyWith({
    int? id,
    double? weight,
    int? reps,
    SetType? setType,
    int? restTime,
    bool? isCompleted,
    double? lastWeight,
    int? lastReps,
  }) {
    return ActiveSet(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      setType: setType ?? this.setType,
      restTime: restTime ?? this.restTime,
      isCompleted: isCompleted ?? this.isCompleted,
      lastWeight: lastWeight ?? this.lastWeight,
      lastReps: lastReps ?? this.lastReps,
    );
  }
}

class ActiveExercise {
  final Exercise exercise;
  final List<ActiveSet> sets;

  ActiveExercise({
    required this.exercise,
    required this.sets,
  });

  ActiveExercise copyWith({
    Exercise? exercise,
    List<ActiveSet>? sets,
  }) {
    return ActiveExercise(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
    );
  }
}

class ActiveWorkoutState {
  final int? sessionId;
  final String name;
  final int? templateId;
  final DateTime? startTime;
  final List<ActiveExercise> exercises;
  final String notes;
  final bool isSaving;
  final bool hasActiveSession;

  ActiveWorkoutState({
    this.sessionId,
    this.name = '',
    this.templateId,
    this.startTime,
    this.exercises = const [],
    this.notes = '',
    this.isSaving = false,
    this.hasActiveSession = false,
  });

  ActiveWorkoutState copyWith({
    int? sessionId,
    String? name,
    int? templateId,
    DateTime? startTime,
    List<ActiveExercise>? exercises,
    String? notes,
    bool? isSaving,
    bool? hasActiveSession,
  }) {
    return ActiveWorkoutState(
      sessionId: sessionId ?? this.sessionId,
      name: name ?? this.name,
      templateId: templateId ?? this.templateId,
      startTime: startTime ?? this.startTime,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      isSaving: isSaving ?? this.isSaving,
      hasActiveSession: hasActiveSession ?? this.hasActiveSession,
    );
  }
}

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  final Ref _ref;
  Timer? _sessionTimer;
  final _durationStreamController = StreamController<Duration>.broadcast();

  ActiveWorkoutNotifier(this._ref) : super(ActiveWorkoutState()) {
    _checkForInProgressSession();
  }

  Stream<Duration> get durationStream => _durationStreamController.stream;

  AppDatabase get _db => _ref.read(databaseProvider);

  void _startDurationTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.startTime != null) {
        final elapsed = DateTime.now().difference(state.startTime!);
        _durationStreamController.add(elapsed);
      }
    });
  }

  void _stopDurationTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  /// Checks if there's a workout session that wasn't closed (i.e. endTime is null)
  Future<void> _checkForInProgressSession() async {
    final allSessions = await _db.getAllWorkoutSessions();
    final inProgress = allSessions.where((s) => s.endTime == null).toList();

    if (inProgress.isNotEmpty) {
      final session = inProgress.first;
      // Load the sets for this session
      final dbSets = await _db.getSetsForSession(session.id);
      
      // Group sets by exercise
      final List<ActiveExercise> activeExercises = [];
      final exerciseIds = dbSets.map((s) => s.exerciseId).toSet();
      final allExercises = await _db.getAllExercises();

      for (final exId in exerciseIds) {
        final exercise = allExercises.firstWhere((e) => e.id == exId);
        final setsForEx = dbSets.where((s) => s.exerciseId == exId).toList();
        
        // Get last set information for micro previews (from previous completed sessions)
        final lastSet = await _db.getLastSetForExercise(exId);

        final activeSets = setsForEx.map((s) {
          return ActiveSet(
            id: s.id,
            weight: s.weight,
            reps: s.reps,
            setType: s.setType,
            restTime: s.restTime,
            isCompleted: s.isCompleted,
            lastWeight: lastSet?.weight,
            lastReps: lastSet?.reps,
          );
        }).toList();

        activeExercises.add(ActiveExercise(exercise: exercise, sets: activeSets));
      }

      state = ActiveWorkoutState(
        sessionId: session.id,
        name: session.name,
        templateId: session.templateId,
        startTime: session.startTime,
        exercises: activeExercises,
        notes: session.notes ?? '',
        hasActiveSession: true,
      );

      _startDurationTimer();
    }
  }

  /// Start a new workout session (optionally from a template)
  Future<void> startWorkout({String name = 'Empty Workout', int? templateId}) async {
    final startTime = DateTime.now();

    // Create session in DB as a draft
    final sessionId = await _db.createWorkoutSession(
      WorkoutSessionsCompanion.insert(
        name: name,
        startTime: startTime,
        templateId: Value(templateId),
      ),
    );

    List<ActiveExercise> activeExercises = [];

    if (templateId != null) {
      // Load exercises from template
      final templateExs = await _db.getTemplateExercises(templateId);
      for (final te in templateExs) {
        final lastSet = await _db.getLastSetForExercise(te.exercise.id);
        
        // Add one default set to start with (based on last set or standard default)
        final defaultWeight = lastSet?.weight ?? 10.0;
        final defaultReps = lastSet?.reps ?? 10;
        
        final newSetCompanion = ExerciseSetsCompanion.insert(
          sessionId: sessionId,
          exerciseId: te.exercise.id,
          weight: defaultWeight,
          reps: defaultReps,
          setType: SetType.Normal,
          restTime: const Value(90),
          isCompleted: const Value(false),
          timestamp: DateTime.now(),
          sequenceOrder: 0,
        );

        final setId = await _db.addExerciseSet(newSetCompanion);

        activeExercises.add(
          ActiveExercise(
            exercise: te.exercise,
            sets: [
              ActiveSet(
                id: setId,
                weight: defaultWeight,
                reps: defaultReps,
                setType: SetType.Normal,
                restTime: 90,
                isCompleted: false,
                lastWeight: lastSet?.weight,
                lastReps: lastSet?.reps,
              )
            ],
          ),
        );
      }
    }

    state = ActiveWorkoutState(
      sessionId: sessionId,
      name: name,
      templateId: templateId,
      startTime: startTime,
      exercises: activeExercises,
      hasActiveSession: true,
    );

    _startDurationTimer();
  }

  /// Add exercise to active session
  Future<void> addExercise(Exercise exercise) async {
    if (state.sessionId == null) return;

    // Check if exercise already exists in this workout
    final exists = state.exercises.any((e) => e.exercise.id == exercise.id);
    if (exists) return;

    final lastSet = await _db.getLastSetForExercise(exercise.id);
    final defaultWeight = lastSet?.weight ?? 10.0;
    final defaultReps = lastSet?.reps ?? 10;

    final newSetCompanion = ExerciseSetsCompanion.insert(
      sessionId: state.sessionId!,
      exerciseId: exercise.id,
      weight: defaultWeight,
      reps: defaultReps,
      setType: SetType.Normal,
      restTime: const Value(90),
      isCompleted: const Value(false),
      timestamp: DateTime.now(),
      sequenceOrder: 0,
    );

    final setId = await _db.addExerciseSet(newSetCompanion);

    final newActiveExercise = ActiveExercise(
      exercise: exercise,
      sets: [
        ActiveSet(
          id: setId,
          weight: defaultWeight,
          reps: defaultReps,
          setType: SetType.Normal,
          restTime: 90,
          isCompleted: false,
          lastWeight: lastSet?.weight,
          lastReps: lastSet?.reps,
        )
      ],
    );

    state = state.copyWith(
      exercises: [...state.exercises, newActiveExercise],
    );
  }

  /// Remove exercise from active session
  Future<void> removeExercise(int exerciseId) async {
    if (state.sessionId == null) return;

    final exerciseToRemove = state.exercises.firstWhere((e) => e.exercise.id == exerciseId);
    
    // Delete sets from database
    for (final s in exerciseToRemove.sets) {
      if (s.id != null) {
        await _db.deleteExerciseSet(s.id!);
      }
    }

    state = state.copyWith(
      exercises: state.exercises.where((e) => e.exercise.id != exerciseId).toList(),
    );
  }

  /// Add set to exercise
  Future<void> addSet(int exerciseId) async {
    if (state.sessionId == null) return;

    final exerciseIndex = state.exercises.indexWhere((e) => e.exercise.id == exerciseId);
    if (exerciseIndex == -1) return;

    final activeEx = state.exercises[exerciseIndex];
    final lastSet = activeEx.sets.isNotEmpty ? activeEx.sets.last : null;

    final defaultWeight = lastSet?.weight ?? 10.0;
    final defaultReps = lastSet?.reps ?? 10;
    final defaultSetType = lastSet?.setType ?? SetType.Normal;
    final defaultRestTime = lastSet?.restTime ?? 90;

    final newSetCompanion = ExerciseSetsCompanion.insert(
      sessionId: state.sessionId!,
      exerciseId: exerciseId,
      weight: defaultWeight,
      reps: defaultReps,
      setType: defaultSetType,
      restTime: Value(defaultRestTime),
      isCompleted: const Value(false),
      timestamp: DateTime.now(),
      sequenceOrder: activeEx.sets.length,
    );

    final setId = await _db.addExerciseSet(newSetCompanion);

    final newSet = ActiveSet(
      id: setId,
      weight: defaultWeight,
      reps: defaultReps,
      setType: defaultSetType,
      restTime: defaultRestTime,
      isCompleted: false,
      lastWeight: activeEx.sets.first.lastWeight,
      lastReps: activeEx.sets.first.lastReps,
    );

    final updatedExercises = List<ActiveExercise>.from(state.exercises);
    updatedExercises[exerciseIndex] = activeEx.copyWith(
      sets: [...activeEx.sets, newSet],
    );

    state = state.copyWith(exercises: updatedExercises);
  }

  /// Remove set from exercise
  Future<void> removeSet(int exerciseId, int setIndex) async {
    final exerciseIndex = state.exercises.indexWhere((e) => e.exercise.id == exerciseId);
    if (exerciseIndex == -1) return;

    final activeEx = state.exercises[exerciseIndex];
    if (activeEx.sets.length <= 1) {
      // If it's the last set, just remove the exercise entirely
      await removeExercise(exerciseId);
      return;
    }

    final setToRemove = activeEx.sets[setIndex];
    if (setToRemove.id != null) {
      await _db.deleteExerciseSet(setToRemove.id!);
    }

    final updatedSets = List<ActiveSet>.from(activeEx.sets)..removeAt(setIndex);
    final updatedExercises = List<ActiveExercise>.from(state.exercises);
    updatedExercises[exerciseIndex] = activeEx.copyWith(sets: updatedSets);

    state = state.copyWith(exercises: updatedExercises);
  }

  /// Update individual set values
  Future<void> updateSet(int exerciseId, int setIndex, ActiveSet updatedSet) async {
    final exerciseIndex = state.exercises.indexWhere((e) => e.exercise.id == exerciseId);
    if (exerciseIndex == -1) return;

    final activeEx = state.exercises[exerciseIndex];
    final originalSet = activeEx.sets[setIndex];

    // Trigger Rest Timer if isCompleted was checked from false to true
    if (updatedSet.isCompleted && !originalSet.isCompleted) {
      _ref.read(restTimerProvider.notifier).startTimer(updatedSet.restTime);
    }

    // Save to DB
    if (updatedSet.id != null) {
      await _db.updateExerciseSet(
        ExerciseSet(
          id: updatedSet.id!,
          sessionId: state.sessionId!,
          exerciseId: exerciseId,
          weight: updatedSet.weight,
          reps: updatedSet.reps,
          setType: updatedSet.setType,
          restTime: updatedSet.restTime,
          isCompleted: updatedSet.isCompleted,
          timestamp: DateTime.now(),
          sequenceOrder: setIndex,
        ),
      );
    }

    final updatedSets = List<ActiveSet>.from(activeEx.sets);
    updatedSets[setIndex] = updatedSet;

    final updatedExercises = List<ActiveExercise>.from(state.exercises);
    updatedExercises[exerciseIndex] = activeEx.copyWith(sets: updatedSets);

    state = state.copyWith(exercises: updatedExercises);
  }

  /// Update workout notes
  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  /// Update workout name
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  /// Finish the active workout
  Future<void> finishWorkout() async {
    if (state.sessionId == null) return;
    state = state.copyWith(isSaving: true);

    // Update the session name and notes in DB
    await (_db.update(_db.workoutSessions)..where((t) => t.id.equals(state.sessionId!))).write(
      WorkoutSessionsCompanion(
        name: Value(state.name),
        notes: Value(state.notes),
        endTime: Value(DateTime.now()),
      ),
    );

    _stopDurationTimer();
    _ref.read(restTimerProvider.notifier).stopTimer();

    state = ActiveWorkoutState();
  }

  /// Cancel and delete active workout
  Future<void> cancelWorkout() async {
    if (state.sessionId == null) return;

    _stopDurationTimer();
    _ref.read(restTimerProvider.notifier).stopTimer();

    // Delete session from DB (cascades sets deletion)
    await _db.deleteWorkoutSession(state.sessionId!);

    state = ActiveWorkoutState();
  }
}

final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>((ref) {
  return ActiveWorkoutNotifier(ref);
});
