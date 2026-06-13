import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import '../models/enums.dart';

part 'database.g.dart';

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get targetMuscle => textEnum<TargetMuscle>()();
  TextColumn get equipment => textEnum<Equipment>()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  TextColumn get imageUrl => text().nullable()();
}

class WorkoutTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
}

class TemplateExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get templateId => integer().references(WorkoutTemplates, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get sequenceOrder => integer()();
}

class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get templateId => integer().nullable().references(WorkoutTemplates, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
}

class ExerciseSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  RealColumn get weight => real()();
  IntColumn get reps => integer()();
  TextColumn get setType => textEnum<SetType>()();
  IntColumn get restTime => integer().withDefault(const Constant(90))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get sequenceOrder => integer()();
}

class TemplateExerciseWithDetail {
  final TemplateExercise templateExercise;
  final Exercise exercise;
  TemplateExerciseWithDetail(this.templateExercise, this.exercise);
}

@DriftDatabase(tables: [
  Exercises,
  WorkoutTemplates,
  TemplateExercises,
  WorkoutSessions,
  ExerciseSets,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await seedDefaultExercises();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(exercises, exercises.imageUrl);
          await _backfillImageUrls();
        }
      },
    );
  }

  Future<void> _backfillImageUrls() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/exercises_seed.json');
      final List<dynamic> jsonList = json.decode(jsonStr);
      for (final item in jsonList) {
        final name = item['name'] as String;
        final imageUrl = item['imageUrl'] as String?;
        if (imageUrl != null) {
          await (update(exercises)..where((t) => t.name.equals(name)))
              .write(ExercisesCompanion(imageUrl: Value(imageUrl)));
        }
      }
    } catch (e) {
      print('Error backfilling image URLs: $e');
    }
  }

  Future<void> seedDefaultExercises() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/exercises_seed.json');
      final List<dynamic> jsonList = json.decode(jsonStr);
      await batch((batch) {
        for (final item in jsonList) {
          batch.insert(
            exercises,
            ExercisesCompanion.insert(
              name: item['name'] as String,
              description: Value(item['description'] as String?),
              targetMuscle: TargetMuscle.fromName(item['targetMuscle'] as String),
              equipment: Equipment.fromName(item['equipment'] as String),
              isCustom: const Value(false),
              imageUrl: Value(item['imageUrl'] as String?),
            ),
          );
        }
      });
    } catch (e) {
      print('Error seeding exercises: $e');
    }
  }

  // --- QUERY HELPER METHODS ---

  // Exercises
  Future<List<Exercise>> getAllExercises() => select(exercises).get();
  Stream<List<Exercise>> watchAllExercises() => select(exercises).watch();
  Future<int> insertExercise(ExercisesCompanion companion) => into(exercises).insert(companion);
  Future<void> deleteExercise(int id) => (delete(exercises)..where((t) => t.id.equals(id))).go();

  // Templates
  Future<int> createTemplate(String name, String? description, List<int> exerciseIds) async {
    return transaction(() async {
      final templateId = await into(workoutTemplates).insert(
        WorkoutTemplatesCompanion.insert(
          name: name,
          description: Value(description),
        ),
      );
      for (int i = 0; i < exerciseIds.length; i++) {
        await into(templateExercises).insert(
          TemplateExercisesCompanion.insert(
            templateId: templateId,
            exerciseId: exerciseIds[i],
            sequenceOrder: i,
          ),
        );
      }
      return templateId;
    });
  }

  Stream<List<WorkoutTemplate>> watchTemplates() => select(workoutTemplates).watch();

  Future<List<TemplateExerciseWithDetail>> getTemplateExercises(int templateId) async {
    final query = select(templateExercises).join([
      innerJoin(exercises, exercises.id.equalsExp(templateExercises.exerciseId)),
    ])..where(templateExercises.templateId.equals(templateId));

    final rows = await query.get();
    return rows.map((row) {
      return TemplateExerciseWithDetail(
        row.readTable(templateExercises),
        row.readTable(exercises),
      );
    }).toList();
  }

  Future<void> deleteTemplate(int templateId) async {
    await (delete(workoutTemplates)..where((t) => t.id.equals(templateId))).go();
  }

  // Sessions
  Future<int> createWorkoutSession(WorkoutSessionsCompanion companion) => into(workoutSessions).insert(companion);
  
  Future<void> finishWorkoutSession(int sessionId, DateTime endTime, String? notes) async {
    await (update(workoutSessions)..where((t) => t.id.equals(sessionId))).write(
      WorkoutSessionsCompanion(
        endTime: Value(endTime),
        notes: Value(notes),
      ),
    );
  }

  Future<void> deleteWorkoutSession(int sessionId) =>
      (delete(workoutSessions)..where((t) => t.id.equals(sessionId))).go();

  Stream<List<WorkoutSession>> watchWorkoutSessions() {
    return (select(workoutSessions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  Future<List<WorkoutSession>> getAllWorkoutSessions() {
    return (select(workoutSessions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.desc)
          ]))
        .get();
  }

  Future<WorkoutSession?> getWorkoutSessionById(int id) {
    return (select(workoutSessions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // Sets
  Future<int> addExerciseSet(ExerciseSetsCompanion companion) => into(exerciseSets).insert(companion);
  Future<void> updateExerciseSet(ExerciseSet set) => update(exerciseSets).replace(set);
  Future<void> deleteExerciseSet(int setId) => (delete(exerciseSets)..where((t) => t.id.equals(setId))).go();
  
  Future<List<ExerciseSet>> getSetsForSession(int sessionId) {
    return (select(exerciseSets)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm(expression: t.sequenceOrder)]))
        .get();
  }

  Stream<List<ExerciseSet>> watchSetsForSession(int sessionId) {
    return (select(exerciseSets)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm(expression: t.sequenceOrder)]))
        .watch();
  }

  Future<ExerciseSet?> getLastSetForExercise(int exerciseId) async {
    final query = select(exerciseSets).join([
      innerJoin(workoutSessions, workoutSessions.id.equalsExp(exerciseSets.sessionId)),
    ])
      ..where(exerciseSets.exerciseId.equals(exerciseId) & exerciseSets.isCompleted.equals(true))
      ..orderBy([OrderingTerm(expression: workoutSessions.endTime, mode: OrderingMode.desc)])
      ..limit(1);

    final row = await query.getSingleOrNull();
    return row?.readTable(exerciseSets);
  }

  Future<List<ExerciseSet>> getAllSetsForExercise(int exerciseId) async {
    final query = select(exerciseSets).join([
      innerJoin(workoutSessions, workoutSessions.id.equalsExp(exerciseSets.sessionId)),
    ])
      ..where(exerciseSets.exerciseId.equals(exerciseId) & exerciseSets.isCompleted.equals(true))
      ..orderBy([OrderingTerm(expression: workoutSessions.startTime, mode: OrderingMode.asc)]);

    final rows = await query.get();
    return rows.map((r) => r.readTable(exerciseSets)).toList();
  }

  // Clear Database
  Future<void> clearDatabase() async {
    await transaction(() async {
      await delete(exerciseSets).go();
      await delete(workoutSessions).go();
      await delete(templateExercises).go();
      await delete(workoutTemplates).go();
      await delete(exercises).go();
      await seedDefaultExercises();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'grit_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
