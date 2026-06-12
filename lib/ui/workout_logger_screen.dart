import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/database_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/workout_provider.dart';
import 'theme.dart';
import 'common/plate_calculator.dart';

class WorkoutLoggerScreen extends ConsumerStatefulWidget {
  const WorkoutLoggerScreen({super.key});

  @override
  ConsumerState<WorkoutLoggerScreen> createState() => _WorkoutLoggerScreenState();
}

class _WorkoutLoggerScreenState extends ConsumerState<WorkoutLoggerScreen> {
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeWorkout = ref.read(activeWorkoutProvider);
      _notesController.text = activeWorkout.notes;
      _nameController.text = activeWorkout.name;
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeWorkout = ref.watch(activeWorkoutProvider);
    final timerState = ref.watch(restTimerProvider);

    if (!activeWorkout.hasActiveSession) {
      return Scaffold(
        appBar: AppBar(title: const Text('Log Workout')),
        body: const Center(child: Text('No active workout session found.')),
      );
    }

    return Scaffold(
      backgroundColor: GritTheme.background,
      appBar: AppBar(
        backgroundColor: GritTheme.surface,
        elevation: 0,
        title: TextField(
          controller: _nameController,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: 18, color: GritTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Workout Name',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            filled: false,
          ),
          onChanged: (val) => ref.read(activeWorkoutProvider.notifier).updateName(val.trim()),
        ),
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: GritTheme.textPrimary, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GestureDetector(
            onTap: () => _confirmFinishWorkout(context),
            child: Container(
              margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: GritTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('FINISH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: GritTheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: GritTheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.timer_rounded, color: GritTheme.primary, size: 16),
                    ),
                    const SizedBox(width: 8),
                    StreamBuilder<Duration>(
                      stream: ref.read(activeWorkoutProvider.notifier).durationStream,
                      builder: (context, snapshot) {
                        final duration = snapshot.data ?? DateTime.now().difference(activeWorkout.startTime!);
                        return Text(_formatDuration(duration),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: GritTheme.textPrimary));
                      },
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _confirmCancelWorkout(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 16),
                  label: const Text('Cancel', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: GritTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: GritTheme.divider, width: 1.5),
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Notes, cues, or motivation...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        filled: false,
                      ),
                      onChanged: (val) => ref.read(activeWorkoutProvider.notifier).updateNotes(val.trim()),
                    ),
                  ),
                  ...activeWorkout.exercises.map((activeEx) => _buildExerciseCard(context, activeEx)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showAddExerciseBottomSheet(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('ADD EXERCISE'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GritTheme.accent,
                      side: const BorderSide(color: GritTheme.accent, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
            if (timerState.isActive) _buildRestTimerBar(timerState),
          ],
        ),
      ),
    );
  }

  Widget _buildRestTimerBar(RestTimerState timerState) {
    final percent = timerState.duration > 0 ? timerState.remainingSeconds / timerState.duration : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: GritTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: GritTheme.accent.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, -4)),
        ],
        border: Border(top: BorderSide(color: GritTheme.accent.withValues(alpha: 0.3), width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(gradient: GritTheme.accentGradient, shape: BoxShape.circle),
                    child: const Icon(Icons.hourglass_bottom_rounded, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rest Timer', style: TextStyle(color: GritTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
                      Text('${timerState.remainingSeconds}s', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: GritTheme.accent)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  _timerAdjustBtn('-30s', -30),
                  const SizedBox(width: 6),
                  _timerAdjustBtn('+30s', 30),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => ref.read(restTimerProvider.notifier).stopTimer(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Text('SKIP', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: GritTheme.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(GritTheme.accent),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timerAdjustBtn(String label, int seconds) {
    return GestureDetector(
      onTap: () => ref.read(restTimerProvider.notifier).adjustTime(seconds),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: GritTheme.surfaceLight, borderRadius: BorderRadius.circular(10)),
        child: Text(label, style: const TextStyle(color: GritTheme.textSecondary, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, ActiveExercise activeEx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GritTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GritTheme.divider, width: 1.5),
        boxShadow: [BoxShadow(color: GritTheme.primary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activeEx.exercise.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: GritTheme.textPrimary)),
                      Text('${activeEx.exercise.targetMuscle.name} • ${activeEx.exercise.equipment.name}',
                          style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: GritTheme.textSecondary),
                  onSelected: (val) {
                    if (val == 'delete') ref.read(activeWorkoutProvider.notifier).removeExercise(activeEx.exercise.id);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'delete', child: Text('Remove Exercise', style: TextStyle(color: Colors.redAccent))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: GritTheme.divider),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.8),
                2: FlexColumnWidth(2.2),
                3: FlexColumnWidth(2.0),
                4: FlexColumnWidth(1.6),
                5: FlexColumnWidth(1.2),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                const TableRow(children: [
                  Text('Set', style: TextStyle(color: GritTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
                  Text('Type', style: TextStyle(color: GritTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
                  Text('Last', style: TextStyle(color: GritTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
                  Text('lbs', style: TextStyle(color: GritTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
                  Text('Reps', style: TextStyle(color: GritTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
                  Text('', style: TextStyle(fontSize: 11)),
                ]),
                ...List.generate(activeEx.sets.length, (index) {
                  final set = activeEx.sets[index];
                  return TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: GritTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.center,
                        child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: DropdownButton<SetType>(
                        value: set.setType,
                        isDense: true,
                        underline: const SizedBox(),
                        icon: const SizedBox(),
                        dropdownColor: GritTheme.surface,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: set.setType == SetType.Normal ? GritTheme.textPrimary : (set.setType == SetType.Warmup ? GritTheme.accentWarm : Colors.redAccent),
                        ),
                        items: SetType.values.map((type) => DropdownMenuItem(value: type, child: Text(type.name[0]))).toList(),
                        onChanged: (val) {
                          if (val != null) ref.read(activeWorkoutProvider.notifier).updateSet(activeEx.exercise.id, index, set.copyWith(setType: val));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        set.lastWeight != null ? '${set.lastWeight!.toStringAsFixed(0)}x${set.lastReps}' : '—',
                        style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: ActiveSetInputField(
                              initialValue: set.weight.toString(),
                              isDecimal: true,
                              isCompleted: set.isCompleted,
                              onChanged: (val) {
                                final weight = double.tryParse(val) ?? 0.0;
                                ref.read(activeWorkoutProvider.notifier).updateSet(activeEx.exercise.id, index, set.copyWith(weight: weight));
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.grid_on_rounded, size: 14, color: GritTheme.textSecondary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => PlateCalculatorModal(defaultTargetWeight: set.weight),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: ActiveSetInputField(
                        initialValue: set.reps.toString(),
                        isDecimal: false,
                        isCompleted: set.isCompleted,
                        onChanged: (val) {
                          final reps = int.tryParse(val) ?? 0;
                          ref.read(activeWorkoutProvider.notifier).updateSet(activeEx.exercise.id, index, set.copyWith(reps: reps));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: InkWell(
                        onTap: () => ref.read(activeWorkoutProvider.notifier).updateSet(activeEx.exercise.id, index, set.copyWith(isCompleted: !set.isCompleted)),
                        onLongPress: () => ref.read(activeWorkoutProvider.notifier).removeSet(activeEx.exercise.id, index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: set.isCompleted ? GritTheme.primaryGradient : null,
                            color: set.isCompleted ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: set.isCompleted ? GritTheme.primaryDark : GritTheme.divider,
                              width: 2,
                            ),
                            boxShadow: set.isCompleted
                                ? [BoxShadow(color: GritTheme.primary.withValues(alpha: 0.3), blurRadius: 6)]
                                : null,
                          ),
                          child: set.isCompleted ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                        ),
                      ),
                    ),
                  ]);
                }),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => ref.read(activeWorkoutProvider.notifier).addSet(activeEx.exercise.id),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Set', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  style: TextButton.styleFrom(foregroundColor: GritTheme.primary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: GritTheme.accentWarm.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    '1RM: ${_calculateEstimated1RM(activeEx.sets).toStringAsFixed(1)} lbs',
                    style: const TextStyle(color: GritTheme.accentWarm, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateEstimated1RM(List<ActiveSet> sets) {
    double max1RM = 0;
    for (final s in sets) {
      if (s.isCompleted && s.reps > 0 && s.weight > 0) {
        double oneRepMax = s.reps > 1 ? s.weight / (1.0278 - (0.0278 * s.reps)) : s.weight;
        if (oneRepMax > max1RM) max1RM = oneRepMax;
      }
    }
    return max1RM;
  }

  void _confirmCancelWorkout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Cancel Workout?'),
          ],
        ),
        content: const Text('This will delete all sets logged in this session.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Going')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel Workout'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await ref.read(activeWorkoutProvider.notifier).cancelWorkout();
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _confirmFinishWorkout(BuildContext context) async {
    final activeWorkout = ref.read(activeWorkoutProvider);
    final hasUncompleted = activeWorkout.exercises.any((ex) => ex.sets.any((s) => !s.isCompleted));

    final finish = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emoji_events_rounded, color: GritTheme.primary),
            SizedBox(width: 8),
            Text('Finish Workout?'),
          ],
        ),
        content: Text(hasUncompleted ? 'You have incomplete sets. Finish anyway?' : 'Great session! Ready to save your progress?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not Yet')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Finish!')),
        ],
      ),
    );
    if (finish == true && context.mounted) {
      await ref.read(activeWorkoutProvider.notifier).finishWorkout();
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _showAddExerciseBottomSheet(BuildContext context) async {
    final allExercises = await ref.read(databaseProvider).getAllExercises();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          final activeWorkout = ref.watch(activeWorkoutProvider);
          final addedIds = activeWorkout.exercises.map((e) => e.exercise.id).toSet();
          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) => Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: GritTheme.divider, borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_rounded, color: GritTheme.primary),
                    SizedBox(width: 8),
                    Text('Add Exercise', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: allExercises.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final ex = allExercises[index];
                      final isAdded = addedIds.contains(ex.id);
                      return ListTile(
                        title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${ex.targetMuscle.name} • ${ex.equipment.name}', style: const TextStyle(fontSize: 12)),
                        trailing: isAdded
                            ? const Icon(Icons.check_circle_rounded, color: GritTheme.success)
                            : const Icon(Icons.add_circle_outline_rounded, color: GritTheme.accent),
                        onTap: isAdded ? null : () async {
                          await ref.read(activeWorkoutProvider.notifier).addExercise(ex);
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ActiveSetInputField extends StatefulWidget {
  final String initialValue;
  final bool isDecimal;
  final bool isCompleted;
  final ValueChanged<String> onChanged;

  const ActiveSetInputField({super.key, required this.initialValue, required this.isDecimal, required this.isCompleted, required this.onChanged});

  @override
  State<ActiveSetInputField> createState() => _ActiveSetInputFieldState();
}

class _ActiveSetInputFieldState extends State<ActiveSetInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant ActiveSetInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text && !FocusScope.of(context).hasFocus) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.numberWithOptions(decimal: widget.isDecimal),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: widget.isCompleted ? GritTheme.textSecondary : GritTheme.textPrimary,
          decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
        ),
        enabled: !widget.isCompleted,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: widget.isCompleted ? Colors.transparent : GritTheme.surfaceLight,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: GritTheme.divider, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: GritTheme.primary, width: 2)),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
