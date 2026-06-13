import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grit/database/database.dart';
import 'package:grit/models/enums.dart';
import 'package:grit/services/program_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Plate Calculator Tests', () {
    final List<double> lbsPlates = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5];

    Map<double, int> calculatePlates(double target, double bar, List<double> plates) {
      if (target <= bar) return {};
      double remaining = (target - bar) / 2;
      Map<double, int> result = {};

      for (final plate in plates) {
        if (remaining >= plate) {
          int count = (remaining / plate).floor();
          result[plate] = count;
          remaining -= count * plate;
          remaining = double.parse(remaining.toStringAsFixed(3));
        }
      }
      return result;
    }

    test('135 lbs bar load (1 plate per side)', () {
      final result = calculatePlates(135, 45, lbsPlates);
      expect(result, {45.0: 1});
    });

    test('225 lbs bar load (2 plates per side)', () {
      final result = calculatePlates(225, 45, lbsPlates);
      expect(result, {45.0: 2});
    });

    test('95 lbs bar load (25 lbs plate per side)', () {
      final result = calculatePlates(95, 45, lbsPlates);
      expect(result, {25.0: 1});
    });

    test('185 lbs bar load (45 lbs + 25 lbs plate per side)', () {
      final result = calculatePlates(185, 45, lbsPlates);
      expect(result, {45.0: 1, 25.0: 1});
    });
  });

  group('1RM Brzycki Calculation Tests', () {
    double calculate1RM(double weight, int reps) {
      if (reps <= 0 || weight <= 0) return 0;
      if (reps == 1) return weight;
      return weight / (1.0278 - (0.0278 * reps));
    }

    test('1 Rep Max for 200 lbs x 5 reps', () {
      final oneRepMax = calculate1RM(200, 5);
      expect(oneRepMax.toStringAsFixed(1), '225.0');
    });

    test('1 Rep Max for 100 lbs x 1 rep', () {
      final oneRepMax = calculate1RM(100, 1);
      expect(oneRepMax, 100.0);
    });

    test('1 Rep Max for 0 lbs or 0 reps', () {
      expect(calculate1RM(0, 5), 0.0);
      expect(calculate1RM(100, 0), 0.0);
    });
  });

  group('Milestone Tracker Tests', () {
    String getMilestoneZone(double position) {
      if (position >= 0.95) return 'Elite';
      if (position >= 0.85) return 'Advanced';
      if (position >= 0.70) return 'Intermediate';
      if (position >= 0.50) return 'Novice';
      return 'Starter';
    }

    Set<String> detectLevelUps(List<double> sessionMax1RMs) {
      final Set<String> levelUps = {};
      double bestSoFar = 0;
      for (int i = 0; i < sessionMax1RMs.length; i++) {
        final rm = sessionMax1RMs[i];
        if (rm > bestSoFar && bestSoFar > 0) {
          levelUps.add('session_$i');
        }
        if (rm > bestSoFar) bestSoFar = rm;
      }
      return levelUps;
    }

    test('Zone calculation: Starter at 0%', () {
      expect(getMilestoneZone(0.0), 'Starter');
    });

    test('Zone calculation: Starter at 49%', () {
      expect(getMilestoneZone(0.49), 'Starter');
    });

    test('Zone calculation: Novice at 50%', () {
      expect(getMilestoneZone(0.50), 'Novice');
    });

    test('Zone calculation: Novice at 69%', () {
      expect(getMilestoneZone(0.69), 'Novice');
    });

    test('Zone calculation: Intermediate at 70%', () {
      expect(getMilestoneZone(0.70), 'Intermediate');
    });

    test('Zone calculation: Intermediate at 84%', () {
      expect(getMilestoneZone(0.84), 'Intermediate');
    });

    test('Zone calculation: Advanced at 85%', () {
      expect(getMilestoneZone(0.85), 'Advanced');
    });

    test('Zone calculation: Advanced at 94%', () {
      expect(getMilestoneZone(0.94), 'Advanced');
    });

    test('Zone calculation: Elite at 95%', () {
      expect(getMilestoneZone(0.95), 'Elite');
    });

    test('Zone calculation: Elite at 100%', () {
      expect(getMilestoneZone(1.0), 'Elite');
    });

    test('Zone calculation: Elite beyond 100%', () {
      expect(getMilestoneZone(1.2), 'Elite');
    });

    test('LEVEL UP detection: new records are detected', () {
      final levelUps = detectLevelUps([100, 120, 110, 150]);
      expect(levelUps, contains('session_1'));
      expect(levelUps, contains('session_3'));
      expect(levelUps.contains('session_0'), false);
      expect(levelUps.contains('session_2'), false);
    });

    test('LEVEL UP detection: no level up on first session', () {
      final levelUps = detectLevelUps([100]);
      expect(levelUps, isEmpty);
    });

    test('LEVEL UP detection: no level up when not improving', () {
      final levelUps = detectLevelUps([100, 80, 90, 75]);
      expect(levelUps, isEmpty);
    });

    test('LEVEL UP detection: multiple consecutive records', () {
      final levelUps = detectLevelUps([100, 110, 120, 130]);
      expect(levelUps, contains('session_1'));
      expect(levelUps, contains('session_2'));
      expect(levelUps, contains('session_3'));
    });

    test('Position clamping: session 1RM equals all-time best', () {
      final position = (200.0 / 200.0).clamp(0.0, 1.0);
      expect(position, 1.0);
    });

    test('Position clamping: session 1RM exceeds all-time best', () {
      final position = (250.0 / 200.0).clamp(0.0, 1.0);
      expect(position, 1.0);
    });

    test('Position calculation: session at half of all-time best', () {
      final position = (100.0 / 200.0).clamp(0.0, 1.0);
      expect(position, 0.5);
    });
  });

  group('Database & Program Generator Tests', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('Program Generation creates templates with new signature', () async {
      final testExercises = [
        ('Squat (Barbell)', TargetMuscle.Quads, Equipment.Barbell),
        ('Bench Press (Barbell)', TargetMuscle.Chest, Equipment.Barbell),
        ('Overhead Press (Barbell)', TargetMuscle.Shoulders, Equipment.Barbell),
        ('Deadlift (Barbell)', TargetMuscle.Hamstrings, Equipment.Barbell),
        ('Pullups', TargetMuscle.Back, Equipment.Bodyweight),
        ('Barbell Row', TargetMuscle.Back, Equipment.Barbell),
        ('Dumbbell Bench Press', TargetMuscle.Chest, Equipment.Dumbbell),
        ('Lateral Raise (Dumbbell)', TargetMuscle.Shoulders, Equipment.Dumbbell),
        ('Incline Dumbbell Press', TargetMuscle.Chest, Equipment.Dumbbell),
        ('Lying Leg Curl (Machine)', TargetMuscle.Hamstrings, Equipment.Machine),
        ('Leg Press', TargetMuscle.Quads, Equipment.Machine),
        ('Romanian Deadlift (Barbell)', TargetMuscle.Hamstrings, Equipment.Barbell),
        ('Barbell Curl', TargetMuscle.Biceps, Equipment.Barbell),
        ('Tricep Pushdown (Cable)', TargetMuscle.Triceps, Equipment.Cables),
        ('Dumbbell Row', TargetMuscle.Back, Equipment.Dumbbell),
        ('Dumbbell Curl', TargetMuscle.Biceps, Equipment.Dumbbell),
        ('Cable Fly', TargetMuscle.Chest, Equipment.Cables),
        ('Face Pull', TargetMuscle.Shoulders, Equipment.Cables),
        ('Leg Extension', TargetMuscle.Quads, Equipment.Machine),
        ('Calf Raise', TargetMuscle.Calves, Equipment.Machine),
        ('Plank', TargetMuscle.Abs, Equipment.Bodyweight),
      ];

      for (final (name, muscle, equip) in testExercises) {
        await db.insertExercise(
          ExercisesCompanion.insert(
            name: name,
            targetMuscle: muscle,
            equipment: equip,
            isCustom: const Value(false),
          ),
        );
      }

      final generator = ProgramGenerator(db);

      final program = await generator.generateProgram(
        daysPerWeek: 3,
        goal: 'Hypertrophy',
        experienceLevel: 'Moderate',
        targetedFocus: {},
        equipment: {'Full Gym'},
      );

      expect(program.days.length, 3);
      expect(program.programName, isNotEmpty);

      for (final day in program.days) {
        expect(day.exercises.length, greaterThanOrEqualTo(4));
        expect(day.name, isNotEmpty);
      }
    });

    test('Beginner profile produces fewer exercises', () async {
      final testExercises = [
        ('Bench Press', TargetMuscle.Chest, Equipment.Barbell),
        ('Squat', TargetMuscle.Quads, Equipment.Barbell),
        ('Row', TargetMuscle.Back, Equipment.Barbell),
        ('Press', TargetMuscle.Shoulders, Equipment.Barbell),
        ('Curl', TargetMuscle.Biceps, Equipment.Barbell),
        ('Extension', TargetMuscle.Triceps, Equipment.Cables),
        ('Leg Press', TargetMuscle.Quads, Equipment.Machine),
        ('Calf Raise', TargetMuscle.Calves, Equipment.Machine),
      ];

      for (final (name, muscle, equip) in testExercises) {
        await db.insertExercise(
          ExercisesCompanion.insert(
            name: name,
            targetMuscle: muscle,
            equipment: equip,
            isCustom: const Value(false),
          ),
        );
      }

      final generator = ProgramGenerator(db);

      final beginnerProgram = await generator.generateProgram(
        daysPerWeek: 2,
        goal: 'Hypertrophy',
        experienceLevel: 'Beginner',
        targetedFocus: {},
        equipment: {'Full Gym'},
      );

      final intermediateProgram = await generator.generateProgram(
        daysPerWeek: 2,
        goal: 'Hypertrophy',
        experienceLevel: 'Intermediate',
        targetedFocus: {},
        equipment: {'Full Gym'},
      );

      final beginnerTotal = beginnerProgram.days.fold<int>(
        0, (sum, day) => sum + day.exercises.length);
      final intermediateTotal = intermediateProgram.days.fold<int>(
        0, (sum, day) => sum + day.exercises.length);

      expect(beginnerTotal, lessThanOrEqualTo(intermediateTotal));
    });

    test('Dynamic naming produces correct format', () {
      final generator = ProgramGenerator(db);

      final name1 = generator.generateProgramName('Beginner', {'Chest'}, 3);
      expect(name1, contains('Beginner'));
      expect(name1, contains('Chest'));
      expect(name1, contains('Split'));

      final name2 = generator.generateProgramName('Intermediate', {}, 5);
      expect(name2, contains('Elite'));
      expect(name2, contains('Cycle'));

      final name3 = generator.generateProgramName('Moderate', {'Back'}, 4);
      expect(name3, contains('Power'));
      expect(name3, contains('Back'));
    });

    test('Equipment filtering works correctly', () async {
      final testExercises = [
        ('Barbell Press', TargetMuscle.Chest, Equipment.Barbell),
        ('Dumbbell Press', TargetMuscle.Chest, Equipment.Dumbbell),
        ('Push-up', TargetMuscle.Chest, Equipment.Bodyweight),
        ('Cable Fly', TargetMuscle.Chest, Equipment.Cables),
      ];

      for (final (name, muscle, equip) in testExercises) {
        await db.insertExercise(
          ExercisesCompanion.insert(
            name: name,
            targetMuscle: muscle,
            equipment: equip,
            isCustom: const Value(false),
          ),
        );
      }

      final generator = ProgramGenerator(db);

      final bodyweightOnly = await generator.generateProgram(
        daysPerWeek: 2,
        goal: 'Hypertrophy',
        experienceLevel: 'Beginner',
        targetedFocus: {},
        equipment: {'Bodyweight'},
      );

      for (final day in bodyweightOnly.days) {
        for (final slot in day.exercises) {
          expect(slot.exercise.equipment, Equipment.Bodyweight);
        }
      }
    });
  });
}
