import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final templatesStreamProvider = StreamProvider<List<WorkoutTemplate>>((ref) {
  return ref.watch(databaseProvider).watchTemplates();
});

final sessionsStreamProvider = StreamProvider<List<WorkoutSession>>((ref) {
  return ref.watch(databaseProvider).watchWorkoutSessions();
});

final exercisesStreamProvider = StreamProvider<List<Exercise>>((ref) {
  return ref.watch(databaseProvider).watchAllExercises();
});
