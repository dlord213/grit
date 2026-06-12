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
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
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
        body: const Center(
          child: Text('No active workout session found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _nameController,
          textAlign: TextAlign.center,
          style: Theme.of(context).appBarTheme.titleTextStyle,
          decoration: const InputDecoration(
            hintText: 'Workout Name',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (val) {
            ref.read(activeWorkoutProvider.notifier).updateName(val.trim());
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Minimize',
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => _confirmFinishWorkout(context),
            child: const Text(
              'FINISH',
              style: TextStyle(color: GritTheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Timer & Stats Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              color: GritTheme.surface.withValues(alpha: 0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.timer, color: GritTheme.primary, size: 18),
                      const SizedBox(width: 6),
                      StreamBuilder<Duration>(
                        stream: ref.read(activeWorkoutProvider.notifier).durationStream,
                        builder: (context, snapshot) {
                          final duration = snapshot.data ??
                              DateTime.now().difference(activeWorkout.startTime!);
                          return Text(
                            _formatDuration(duration),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          );
                        },
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmCancelWorkout(context),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 16),
                    label: const Text('Cancel Workout', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
                ],
              ),
            ),

            // Exercise List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Workout Notes
                  TextField(
                    controller: _notesController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Add workout notes / motivation here...',
                      labelText: 'Workout Notes',
                      alignLabelWithHint: true,
                    ),
                    onChanged: (val) {
                      ref.read(activeWorkoutProvider.notifier).updateNotes(val.trim());
                    },
                  ),
                  const SizedBox(height: 16),

                  // Exercises list
                  ...activeWorkout.exercises.map((activeEx) {
                    return _buildExerciseCard(context, activeEx);
                  }),

                  const SizedBox(height: 12),
                  // Add Exercise Button
                  OutlinedButton.icon(
                    onPressed: () => _showAddExerciseBottomSheet(context),
                    icon: const Icon(Icons.add),
                    label: const Text('ADD EXERCISE'),
                  ),
                  const SizedBox(height: 80), // Space for floating timer
                ],
              ),
            ),

            // Floating Rest Timer Bar at Bottom
            if (timerState.isActive) _buildRestTimerBar(timerState),
          ],
        ),
      ),
    );
  }

  Widget _buildRestTimerBar(RestTimerState timerState) {
    final percent = timerState.duration > 0
        ? timerState.remainingSeconds / timerState.duration
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: GritTheme.surface,
        border: const Border(top: BorderSide(color: GritTheme.divider, width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rest Timer', style: TextStyle(color: GritTheme.textSecondary, fontSize: 12)),
                  Text(
                    '${timerState.remainingSeconds}s remaining',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: GritTheme.primary),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: GritTheme.textPrimary),
                    onPressed: () => ref.read(restTimerProvider.notifier).adjustTime(-30),
                  ),
                  const Text('-30s', style: TextStyle(fontSize: 12)),
                  IconButton(
                    icon: const Icon(Icons.add, color: GritTheme.textPrimary),
                    onPressed: () => ref.read(restTimerProvider.notifier).adjustTime(30),
                  ),
                  const Text('+30s', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => ref.read(restTimerProvider.notifier).stopTimer(),
                    child: const Text('SKIP', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: GritTheme.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(GritTheme.primary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, ActiveExercise activeEx) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                      Text(
                        activeEx.exercise.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${activeEx.exercise.targetMuscle.name} • ${activeEx.exercise.equipment.name}',
                        style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: GritTheme.textSecondary),
                  onSelected: (val) {
                    if (val == 'delete') {
                      ref.read(activeWorkoutProvider.notifier).removeExercise(activeEx.exercise.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete Exercise', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Set List Table
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2), // Set num
                1: FlexColumnWidth(1.8), // Type
                2: FlexColumnWidth(2.2), // Last Time
                3: FlexColumnWidth(2.0), // Weight (Lbs)
                4: FlexColumnWidth(1.6), // Reps
                5: FlexColumnWidth(1.2), // Complete check
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                const TableRow(
                  children: [
                    Text('Set', style: TextStyle(color: GritTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('Type', style: TextStyle(color: GritTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('Last Time', style: TextStyle(color: GritTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('lbs', style: TextStyle(color: GritTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('Reps', style: TextStyle(color: GritTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('', style: TextStyle(color: GritTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                ...List.generate(activeEx.sets.length, (index) {
                  final set = activeEx.sets[index];
                  return TableRow(
                    children: [
                      // Set num
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text('${index + 1}'),
                      ),
                      // Set Type Dropdown
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
                            color: set.setType == SetType.Normal
                                ? GritTheme.textPrimary
                                : (set.setType == SetType.Warmup ? Colors.amber : Colors.redAccent),
                          ),
                          items: SetType.values
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type.name[0]), // Show short character W, N, D, F
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(activeWorkoutProvider.notifier).updateSet(
                                    activeEx.exercise.id,
                                    index,
                                    set.copyWith(setType: val),
                                  );
                            }
                          },
                        ),
                      ),
                      // Last Time Micro Preview
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          set.lastWeight != null
                              ? '${set.lastWeight!.toStringAsFixed(0)}x${set.lastReps}'
                              : '—',
                          style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12),
                        ),
                      ),
                      // Weight Input + Plate Calculator Trigger
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
                                  ref.read(activeWorkoutProvider.notifier).updateSet(
                                        activeEx.exercise.id,
                                        index,
                                        set.copyWith(weight: weight),
                                      );
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.grid_on, size: 14, color: GritTheme.textSecondary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => PlateCalculatorModal(
                                    defaultTargetWeight: set.weight,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Reps Input
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        child: ActiveSetInputField(
                          initialValue: set.reps.toString(),
                          isDecimal: false,
                          isCompleted: set.isCompleted,
                          onChanged: (val) {
                            final reps = int.tryParse(val) ?? 0;
                            ref.read(activeWorkoutProvider.notifier).updateSet(
                                  activeEx.exercise.id,
                                  index,
                                  set.copyWith(reps: reps),
                                );
                          },
                        ),
                      ),
                      // Complete Checkbox
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () {
                            ref.read(activeWorkoutProvider.notifier).updateSet(
                                  activeEx.exercise.id,
                                  index,
                                  set.copyWith(isCompleted: !set.isCompleted),
                                );
                          },
                          onLongPress: () {
                            // Long press deletes set
                            ref.read(activeWorkoutProvider.notifier).removeSet(activeEx.exercise.id, index);
                          },
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: set.isCompleted ? GritTheme.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: set.isCompleted ? GritTheme.primary : GritTheme.divider,
                                width: 1.5,
                              ),
                            ),
                            child: set.isCompleted
                                ? const Icon(Icons.check, size: 14, color: GritTheme.background)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => ref.read(activeWorkoutProvider.notifier).addSet(activeEx.exercise.id),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Set', style: TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(foregroundColor: GritTheme.primary),
                ),
                Text(
                  '1RM: ${_calculateEstimated1RM(activeEx.sets).toStringAsFixed(1)} lbs',
                  style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12),
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
        // Brzycki formula: 1RM = Weight / (1.0278 - (0.0278 * Reps))
        double oneRepMax = s.weight;
        if (s.reps > 1) {
          oneRepMax = s.weight / (1.0278 - (0.0278 * s.reps));
        }
        if (oneRepMax > max1RM) {
          max1RM = oneRepMax;
        }
      }
    }
    return max1RM;
  }

  void _confirmCancelWorkout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GritTheme.surface,
        title: const Text('Cancel Workout?'),
        content: const Text('Are you sure you want to cancel this workout? This will delete all sets logged in this session.'),
        actions: [
          TextButton(
            child: const Text('Keep Working', style: TextStyle(color: GritTheme.textSecondary)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Cancel Workout'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(activeWorkoutProvider.notifier).cancelWorkout();
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _confirmFinishWorkout(BuildContext context) async {
    final activeWorkout = ref.read(activeWorkoutProvider);
    
    // Check if there are uncompleted sets
    bool hasUncompleted = false;
    for (final ex in activeWorkout.exercises) {
      if (ex.sets.any((s) => !s.isCompleted)) {
        hasUncompleted = true;
        break;
      }
    }

    final finish = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GritTheme.surface,
        title: const Text('Finish Workout?'),
        content: Text(hasUncompleted
            ? 'You have sets that are not marked as completed. Finish anyway?'
            : 'Are you ready to log this workout and save your progress?'),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: GritTheme.textSecondary)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text('Finish'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (finish == true && context.mounted) {
      await ref.read(activeWorkoutProvider.notifier).finishWorkout();
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showAddExerciseBottomSheet(BuildContext context) async {
    final allExercises = await ref.read(databaseProvider).getAllExercises();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GritTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final activeWorkout = ref.watch(activeWorkoutProvider);
          final addedIds = activeWorkout.exercises.map((e) => e.exercise.id).toSet();
          
          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(color: GritTheme.divider, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Add Exercise', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: allExercises.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final ex = allExercises[index];
                        final isAdded = addedIds.contains(ex.id);

                        return ListTile(
                          title: Text(ex.name),
                          subtitle: Text('${ex.targetMuscle.name} • ${ex.equipment.name}', style: const TextStyle(fontSize: 12)),
                          trailing: isAdded
                              ? const Icon(Icons.check_circle, color: GritTheme.primary)
                              : const Icon(Icons.add_circle_outline, color: GritTheme.textSecondary),
                          onTap: isAdded
                              ? null
                              : () async {
                                  await ref.read(activeWorkoutProvider.notifier).addExercise(ex);
                                  setState(() {});
                                },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
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

  const ActiveSetInputField({
    super.key,
    required this.initialValue,
    required this.isDecimal,
    required this.isCompleted,
    required this.onChanged,
  });

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
      height: 28,
      child: TextField(
        controller: _controller,
        keyboardType: TextInputType.numberWithOptions(decimal: widget.isDecimal),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: widget.isCompleted ? GritTheme.textSecondary : GritTheme.textPrimary,
          decoration: widget.isCompleted ? TextDecoration.lineThrough : null,
        ),
        enabled: !widget.isCompleted,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: widget.isCompleted
              ? Colors.transparent
              : GritTheme.surfaceLight.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: GritTheme.divider, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: GritTheme.primary, width: 1.5),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
