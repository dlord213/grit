import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/database_provider.dart';
import '../services/program_generator.dart';
import 'forging_canvas_screen.dart';
import 'theme.dart';

class SplitReviewScreen extends ConsumerStatefulWidget {
  final GeneratedProgram program;

  const SplitReviewScreen({super.key, required this.program});

  @override
  ConsumerState<SplitReviewScreen> createState() => _SplitReviewScreenState();
}

class _SplitReviewScreenState extends ConsumerState<SplitReviewScreen> {
  late List<DayPlan> _days;
  bool _isForging = false;

  @override
  void initState() {
    super.initState();
    _days = widget.program.days
        .map((d) => DayPlan(
              name: d.name,
              description: d.description,
              exercises: List.from(d.exercises),
            ))
        .toList();
  }

  Set<int> _getUsedIds() {
    final ids = <int>{};
    for (final day in _days) {
      for (final slot in day.exercises) {
        ids.add(slot.exercise.id);
      }
    }
    return ids;
  }

  void _rerollExercise(int dayIndex, int exerciseIndex) async {
    final db = ref.read(databaseProvider);
    final allExercises = await db.getAllExercises();
    final generator = ProgramGenerator(db);

    final usedIds = _getUsedIds();
    final slot = _days[dayIndex].exercises[exerciseIndex];
    final newSlot = generator.rerollExercise(slot, allExercises, usedIds);

    setState(() {
      _days[dayIndex].exercises[exerciseIndex] = newSlot;
    });
  }

  Future<void> _forgeProgram() async {
    setState(() {
      _isForging = true;
    });

    try {
      final db = ref.read(databaseProvider);
      for (final day in _days) {
        final exerciseIds = day.exercises.map((s) => s.exercise.id).toList();
        await db.createTemplate(day.name, day.description, exerciseIds);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Forged ${_days.length} workout templates!'),
            backgroundColor: GritTheme.primary,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error forging program: $e'),
            backgroundColor: GritTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isForging = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isForging) {
      return const ForgingCanvas();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Review Your Split'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.program.programName,
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Review each day and re-roll exercises you want to swap.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._days.asMap().entries.map((entry) {
                    final dayIndex = entry.key;
                    final day = entry.value;
                    return _buildDayCard(dayIndex, day);
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _forgeProgram,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text(
                  'FORGE THIS PROGRAM',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(int dayIndex, DayPlan day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 2.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GritTheme.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
            child: Text(
              day.name,
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: GritTheme.primary,
              ),
            ),
          ),
          ...day.exercises.asMap().entries.map((entry) {
            final exerciseIndex = entry.key;
            final slot = entry.value;
            return _buildExerciseRow(dayIndex, exerciseIndex, slot);
          }),
        ],
      ),
    );
  }

  Widget _buildExerciseRow(int dayIndex, int exerciseIndex, ExerciseSlot slot) {
    final muscleColor = _getMuscleColor(slot.targetMuscle);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: muscleColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.exercise.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _buildMuscleBadge(slot.targetMuscle.name, muscleColor),
                    const SizedBox(width: 8),
                    Text(
                      slot.exercise.equipment.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _rerollExercise(dayIndex, exerciseIndex),
            icon: Icon(
              Icons.refresh_rounded,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              size: 20,
            ),
            tooltip: 'Swap exercise',
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _getMuscleColor(TargetMuscle muscle) {
    switch (muscle) {
      case TargetMuscle.Chest:
        return const Color(0xFFFF6B9D);
      case TargetMuscle.Back:
        return const Color(0xFF4ECAFF);
      case TargetMuscle.Quads:
        return const Color(0xFF7B61FF);
      case TargetMuscle.Hamstrings:
        return const Color(0xFF9B59B6);
      case TargetMuscle.Shoulders:
        return const Color(0xFFFF9F43);
      case TargetMuscle.Biceps:
        return const Color(0xFF26DE81);
      case TargetMuscle.Triceps:
        return const Color(0xFFFC5C65);
      case TargetMuscle.Abs:
        return const Color(0xFFFED330);
      case TargetMuscle.Calves:
        return const Color(0xFF45AAF2);
      case TargetMuscle.FullBody:
        return const Color(0xFFA5B1C2);
    }
  }
}
