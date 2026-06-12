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

  group('Database & Program Generator Tests', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('Program Generation creates templates and clones exercises', () async {
      // 1. Manually seed exercises because rootBundle won't be available in standard unit test
      final testExercises = [
        'Squat (Barbell)',
        'Bench Press (Barbell)',
        'Overhead Press (Barbell)',
        'Deadlift (Barbell)',
        'Pullups',
        'Barbell Row',
        'Dumbbell Bench Press',
        'Lateral Raise (Dumbbell)',
        'Incline Dumbbell Press',
        'Lying Leg Curl (Machine)',
        'Leg Press',
        'Romanian Deadlift (Barbell)',
        'Barbell Curl',
        'Tricep Pushdown (Cable)',
      ];

      for (final name in testExercises) {
        await db.insertExercise(
          ExercisesCompanion.insert(
            name: name,
            targetMuscle: TargetMuscle.Chest,
            equipment: Equipment.Barbell,
            isCustom: const Value(false),
          ),
        );
      }

      final generator = ProgramGenerator(db);

      // 2. Generate a 3-Day Hypertrophy program
      final count = await generator.generateProgram(
        daysPerWeek: 3,
        goal: 'Hypertrophy',
        equipment: 'Full Gym',
      );

      // Verify that templates were created
      expect(count, 3);
      final templates = await db.select(db.workoutTemplates).get();
      expect(templates.length, 3);
      expect(templates[0].name, isNotEmpty);
      expect(templates[1].name, isNotEmpty);
      expect(templates[2].name, isNotEmpty);

      // Verify template exercises were linked
      final tempExs = await db.getTemplateExercises(templates[0].id);
      expect(tempExs.isNotEmpty, true);
    });
  });
}
