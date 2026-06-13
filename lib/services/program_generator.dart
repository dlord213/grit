import 'dart:math';
import '../database/database.dart';
import '../models/enums.dart';

class GeneratedProgram {
  final List<DayPlan> days;
  final String programName;

  GeneratedProgram({required this.days, required this.programName});
}

class DayPlan {
  String name;
  String description;
  final List<ExerciseSlot> exercises;

  DayPlan({
    required this.name,
    required this.description,
    required this.exercises,
  });
}

class ExerciseSlot {
  Exercise exercise;
  final TargetMuscle targetMuscle;
  final bool isAccessory;

  ExerciseSlot({
    required this.exercise,
    required this.targetMuscle,
    this.isAccessory = false,
  });
}

class _ExperienceProfile {
  final int minExercises;
  final int maxExercises;
  final int minSets;
  final int maxSets;
  final bool preferMachines;

  _ExperienceProfile(
    this.minExercises,
    this.maxExercises,
    this.minSets,
    this.maxSets, {
    this.preferMachines = false,
  });

  static _ExperienceProfile fromLevel(String level) {
    switch (level) {
      case 'Beginner':
        return _ExperienceProfile(4, 5, 2, 3, preferMachines: true);
      case 'Moderate':
        return _ExperienceProfile(5, 6, 3, 3);
      case 'Intermediate':
        return _ExperienceProfile(6, 7, 3, 4);
      default:
        return _ExperienceProfile(5, 6, 3, 3);
    }
  }
}

class ProgramGenerator {
  final AppDatabase db;
  final Random _random = Random();

  ProgramGenerator(this.db);

  Future<GeneratedProgram> generateProgram({
    required int daysPerWeek,
    required String goal,
    required String experienceLevel,
    required Set<String> targetedFocus,
    required Set<String> equipment,
  }) async {
    final allExercises = await db.getAllExercises();
    final available = _filterExercisesByEquipment(allExercises, equipment);
    final profile = _ExperienceProfile.fromLevel(experienceLevel);
    final splitDays = _resolveSplitFramework(daysPerWeek, goal);

    final List<DayPlan> dayPlans = [];
    final Set<int> usedExerciseIds = {};

    for (final dayDef in splitDays) {
      final exercises = _fillDaySlots(
        dayDef,
        available,
        profile,
        targetedFocus,
        usedExerciseIds,
      );
      dayPlans.add(DayPlan(
        name: '',
        description: dayDef['description'] as String,
        exercises: exercises,
      ));
    }

    _applyFocusReordering(dayPlans, targetedFocus, profile);

    final programName = generateProgramName(experienceLevel, targetedFocus, daysPerWeek);
    _assignDayNames(dayPlans, programName);

    return GeneratedProgram(days: dayPlans, programName: programName);
  }

  List<Exercise> _filterExercisesByEquipment(
    List<Exercise> allExercises,
    Set<String> equipment,
  ) {
    final Set<Equipment> allowedEquipment = {};
    for (final label in equipment) {
      switch (label) {
        case 'Full Gym':
          allowedEquipment.addAll([
            Equipment.Barbell,
            Equipment.Dumbbell,
            Equipment.Machine,
            Equipment.Cables,
            Equipment.SmithMachine,
          ]);
          break;
        case 'Home Gym':
          allowedEquipment.addAll([Equipment.Barbell, Equipment.Dumbbell]);
          break;
        case 'Dumbbell Only':
          allowedEquipment.add(Equipment.Dumbbell);
          break;
        case 'Bodyweight':
          allowedEquipment.add(Equipment.Bodyweight);
          break;
      }
    }
    if (allowedEquipment.isEmpty) {
      allowedEquipment.addAll(Equipment.values);
    }
    return allExercises
        .where((e) => allowedEquipment.contains(e.equipment))
        .toList();
  }

  List<Map<String, dynamic>> _resolveSplitFramework(int days, String goal) {
    switch (days) {
      case 2:
        return [
          {'name': 'Full Body A', 'description': 'Full body compound session.', 'slots': [
            {'muscle': TargetMuscle.Chest, 'count': 1},
            {'muscle': TargetMuscle.Back, 'count': 1},
            {'muscle': TargetMuscle.Quads, 'count': 1},
            {'muscle': TargetMuscle.Shoulders, 'count': 1},
            {'muscle': TargetMuscle.Biceps, 'count': 1},
            {'muscle': TargetMuscle.Abs, 'count': 1},
          ]},
          {'name': 'Full Body B', 'description': 'Full body accessory session.', 'slots': [
            {'muscle': TargetMuscle.Chest, 'count': 1},
            {'muscle': TargetMuscle.Back, 'count': 1},
            {'muscle': TargetMuscle.Hamstrings, 'count': 1},
            {'muscle': TargetMuscle.Shoulders, 'count': 1},
            {'muscle': TargetMuscle.Triceps, 'count': 1},
            {'muscle': TargetMuscle.Abs, 'count': 1},
          ]},
        ];
      case 3:
        if (goal == 'Strength') {
          return [
            {'name': 'Squat Focus', 'description': 'Heavy squat and pressing day.', 'slots': [
              {'muscle': TargetMuscle.Quads, 'count': 2},
              {'muscle': TargetMuscle.Chest, 'count': 1},
              {'muscle': TargetMuscle.Back, 'count': 1},
              {'muscle': TargetMuscle.Abs, 'count': 1},
            ]},
            {'name': 'Bench Focus', 'description': 'Heavy bench and pulling day.', 'slots': [
              {'muscle': TargetMuscle.Chest, 'count': 2},
              {'muscle': TargetMuscle.Back, 'count': 1},
              {'muscle': TargetMuscle.Biceps, 'count': 1},
              {'muscle': TargetMuscle.Abs, 'count': 1},
            ]},
            {'name': 'Deadlift Focus', 'description': 'Heavy deadlift and accessory day.', 'slots': [
              {'muscle': TargetMuscle.Hamstrings, 'count': 2},
              {'muscle': TargetMuscle.Back, 'count': 1},
              {'muscle': TargetMuscle.Triceps, 'count': 1},
              {'muscle': TargetMuscle.Calves, 'count': 1},
            ]},
          ];
        } else {
          return [
            {'name': 'Push', 'description': 'Push day targeting chest, shoulders, and triceps.', 'slots': [
              {'muscle': TargetMuscle.Chest, 'count': 2},
              {'muscle': TargetMuscle.Shoulders, 'count': 1},
              {'muscle': TargetMuscle.Triceps, 'count': 1},
              {'muscle': TargetMuscle.Abs, 'count': 1},
            ]},
            {'name': 'Pull', 'description': 'Pull day targeting back and biceps.', 'slots': [
              {'muscle': TargetMuscle.Back, 'count': 2},
              {'muscle': TargetMuscle.Biceps, 'count': 2},
              {'muscle': TargetMuscle.Abs, 'count': 1},
            ]},
            {'name': 'Legs', 'description': 'Lower body day targeting quads, hamstrings, and calves.', 'slots': [
              {'muscle': TargetMuscle.Quads, 'count': 2},
              {'muscle': TargetMuscle.Hamstrings, 'count': 1},
              {'muscle': TargetMuscle.Calves, 'count': 1},
              {'muscle': TargetMuscle.Abs, 'count': 1},
            ]},
          ];
        }
      case 4:
        return [
          {'name': 'Upper A', 'description': 'Upper body power day.', 'slots': [
            {'muscle': TargetMuscle.Chest, 'count': 2},
            {'muscle': TargetMuscle.Back, 'count': 2},
            {'muscle': TargetMuscle.Shoulders, 'count': 1},
            {'muscle': TargetMuscle.Biceps, 'count': 1},
          ]},
          {'name': 'Lower A', 'description': 'Lower body squat focus.', 'slots': [
            {'muscle': TargetMuscle.Quads, 'count': 2},
            {'muscle': TargetMuscle.Hamstrings, 'count': 1},
            {'muscle': TargetMuscle.Calves, 'count': 1},
            {'muscle': TargetMuscle.Abs, 'count': 1},
          ]},
          {'name': 'Upper B', 'description': 'Upper body hypertrophy day.', 'slots': [
            {'muscle': TargetMuscle.Chest, 'count': 1},
            {'muscle': TargetMuscle.Back, 'count': 2},
            {'muscle': TargetMuscle.Shoulders, 'count': 1},
            {'muscle': TargetMuscle.Triceps, 'count': 1},
          ]},
          {'name': 'Lower B', 'description': 'Lower body hinge focus.', 'slots': [
            {'muscle': TargetMuscle.Hamstrings, 'count': 2},
            {'muscle': TargetMuscle.Quads, 'count': 1},
            {'muscle': TargetMuscle.Calves, 'count': 1},
            {'muscle': TargetMuscle.Abs, 'count': 1},
          ]},
        ];
      case 5:
      default:
        return [
          {'name': 'Upper Power', 'description': 'Heavy upper body compounds.', 'slots': [
            {'muscle': TargetMuscle.Chest, 'count': 2},
            {'muscle': TargetMuscle.Back, 'count': 2},
            {'muscle': TargetMuscle.Shoulders, 'count': 1},
          ]},
          {'name': 'Lower Power', 'description': 'Heavy lower body compounds.', 'slots': [
            {'muscle': TargetMuscle.Quads, 'count': 2},
            {'muscle': TargetMuscle.Hamstrings, 'count': 1},
            {'muscle': TargetMuscle.Calves, 'count': 1},
          ]},
          {'name': 'Push', 'description': 'Hypertrophy push day.', 'slots': [
            {'muscle': TargetMuscle.Chest, 'count': 2},
            {'muscle': TargetMuscle.Shoulders, 'count': 1},
            {'muscle': TargetMuscle.Triceps, 'count': 1},
          ]},
          {'name': 'Pull', 'description': 'Hypertrophy pull day.', 'slots': [
            {'muscle': TargetMuscle.Back, 'count': 2},
            {'muscle': TargetMuscle.Biceps, 'count': 2},
          ]},
          {'name': 'Legs', 'description': 'Hypertrophy leg day.', 'slots': [
            {'muscle': TargetMuscle.Quads, 'count': 1},
            {'muscle': TargetMuscle.Hamstrings, 'count': 2},
            {'muscle': TargetMuscle.Calves, 'count': 1},
          ]},
        ];
    }
  }

  List<ExerciseSlot> _fillDaySlots(
    Map<String, dynamic> dayDef,
    List<Exercise> available,
    _ExperienceProfile profile,
    Set<String> targetedFocus,
    Set<int> usedExerciseIds,
  ) {
    final slots = List<Map<String, dynamic>>.from(dayDef['slots'] as List);
    final targetCount = _random.nextInt(profile.maxExercises - profile.minExercises + 1) +
        profile.minExercises;

    final List<ExerciseSlot> result = [];
    int slotsFilled = 0;

    for (final slotDef in slots) {
      final muscle = slotDef['muscle'] as TargetMuscle;
      final count = slotDef['count'] as int;

      for (int i = 0; i < count && slotsFilled < targetCount; i++) {
        final exercise = _pickExercise(
          available,
          muscle,
          profile.preferMachines,
          usedExerciseIds,
        );
        if (exercise != null) {
          result.add(ExerciseSlot(
            exercise: exercise,
            targetMuscle: muscle,
            isAccessory: i > 0,
          ));
          usedExerciseIds.add(exercise.id);
          slotsFilled++;
        }
      }
    }

    while (slotsFilled < profile.minExercises) {
      final fallbackMuscle = TargetMuscle.values[_random.nextInt(TargetMuscle.values.length)];
      final exercise = _pickExercise(
        available,
        fallbackMuscle,
        profile.preferMachines,
        usedExerciseIds,
      );
      if (exercise != null) {
        result.add(ExerciseSlot(
          exercise: exercise,
          targetMuscle: fallbackMuscle,
          isAccessory: true,
        ));
        usedExerciseIds.add(exercise.id);
        slotsFilled++;
      } else {
        break;
      }
    }

    return result;
  }

  Exercise? _pickExercise(
    List<Exercise> available,
    TargetMuscle muscle,
    bool preferMachines,
    Set<int> usedIds,
  ) {
    final candidates = available
        .where((e) => e.targetMuscle == muscle && !usedIds.contains(e.id))
        .toList();

    if (candidates.isEmpty) return null;

    if (preferMachines) {
      final machineCandidates = candidates
          .where((e) => e.equipment == Equipment.Machine || e.equipment == Equipment.Cables)
          .toList();
      if (machineCandidates.isNotEmpty) {
        return machineCandidates[_random.nextInt(machineCandidates.length)];
      }
    }

    return candidates[_random.nextInt(candidates.length)];
  }

  void _applyFocusReordering(
    List<DayPlan> dayPlans,
    Set<String> targetedFocus,
    _ExperienceProfile profile,
  ) {
    if (targetedFocus.isEmpty) return;

    final focusedMuscles = <TargetMuscle>{};
    for (final focusName in targetedFocus) {
      final focus = MuscleFocus.fromName(focusName);
      focusedMuscles.addAll(focus.targetMuscles);
    }

    for (final day in dayPlans) {
      day.exercises.sort((a, b) {
        final aFocused = focusedMuscles.contains(a.targetMuscle) ? 0 : 1;
        final bFocused = focusedMuscles.contains(b.targetMuscle) ? 0 : 1;
        return aFocused.compareTo(bFocused);
      });

      if (profile == _ExperienceProfile.fromLevel('Intermediate') && focusedMuscles.isNotEmpty) {
        final accessoryIdx = day.exercises.indexWhere(
          (s) => s.isAccessory && !focusedMuscles.contains(s.targetMuscle),
        );
        if (accessoryIdx != -1) {
          final focusMuscle = focusedMuscles.first;
          final replacement = _pickExercise(
            [],
            focusMuscle,
            false,
            day.exercises.map((s) => s.exercise.id).toSet(),
          );
          if (replacement != null) {
            day.exercises[accessoryIdx] = ExerciseSlot(
              exercise: replacement,
              targetMuscle: focusMuscle,
              isAccessory: true,
            );
          }
        }
      }
    }
  }

  String generateProgramName(
    String experience,
    Set<String> focus,
    int days,
  ) {
    final primaryFocus = focus.isNotEmpty ? focus.first : null;

    String prefix;
    if (experience == 'Beginner') {
      prefix = primaryFocus != null ? 'Beginner ${primaryFocus} Crusher' : 'Beginner Foundation Builder';
    } else if (experience == 'Intermediate') {
      prefix = primaryFocus != null ? 'Elite ${primaryFocus} Warrior' : 'Elite Power Builder';
    } else {
      prefix = primaryFocus != null ? 'Power ${primaryFocus} Shaper' : 'Balanced Power Builder';
    }

    final suffix = days <= 3 ? 'Split' : 'Cycle';
    return '$prefix ($suffix)';
  }

  void _assignDayNames(List<DayPlan> dayPlans, String programName) {
    for (int i = 0; i < dayPlans.length; i++) {
      final day = dayPlans[i];
      final dayLabel = 'Day ${i + 1}';
      day.name = '$programName — $dayLabel (${day.name})';
    }
  }

  ExerciseSlot rerollExercise(
    ExerciseSlot slot,
    List<Exercise> allAvailable,
    Set<int> usedIds,
  ) {
    final candidates = allAvailable
        .where((e) =>
            e.targetMuscle == slot.targetMuscle &&
            !usedIds.contains(e.id) &&
            e.id != slot.exercise.id)
        .toList();

    if (candidates.isEmpty) return slot;

    final newExercise = candidates[_random.nextInt(candidates.length)];
    return ExerciseSlot(
      exercise: newExercise,
      targetMuscle: slot.targetMuscle,
      isAccessory: slot.isAccessory,
    );
  }
}
