import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../models/enums.dart';
import '../providers/database_provider.dart';
import '../providers/workout_provider.dart';
import 'theme.dart';
import 'program_questionnaire_screen.dart';
import 'workout_logger_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesStreamProvider);
    final sessionsAsync = ref.watch(sessionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt, color: GritTheme.primary, size: 28),
            const SizedBox(width: 8),
            Text(
              'GRIT',
              style: TextStyle(
                fontFamily: 'Outfit',
                letterSpacing: 2.0,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [GritTheme.primaryLight, GritTheme.accent],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: GritTheme.primary),
            tooltip: 'Create Template',
            onPressed: () => _showCreateTemplateDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Streams update automatically
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Weekly Consistency Streak Tracker
                sessionsAsync.when(
                  data: (sessions) => _buildStreakTracker(context, sessions),
                  loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                  error: (e, s) => const SizedBox(),
                ),
                const SizedBox(height: 20),

                // 2. Program Generator Questionnaire Banner
                _buildProgramBanner(context),
                const SizedBox(height: 24),

                // 3. Start empty workout button
                ElevatedButton.icon(
                  onPressed: () async {
                    final activeWorkoutNotifier = ref.read(activeWorkoutProvider.notifier);
                    await activeWorkoutNotifier.startWorkout(name: 'Empty Workout');
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WorkoutLoggerScreen()),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                  label: const Text('START EMPTY WORKOUT'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: GritTheme.primary,
                    foregroundColor: GritTheme.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 28),

                // 4. Templates Section
                Text(
                  'Workout Templates',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 12),
                templatesAsync.when(
                  data: (templates) => _buildTemplatesGrid(context, ref, templates),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error loading templates: $e'),
                ),
                const SizedBox(height: 28),

                // 5. History Section
                Text(
                  'Recent Workouts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 12),
                sessionsAsync.when(
                  data: (sessions) => _buildRecentHistory(context, ref, sessions),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error loading history: $e'),
                ),
                const SizedBox(height: 60), // Add padding for floating active session bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakTracker(BuildContext context, List<WorkoutSession> sessions) {
    final now = DateTime.now();
    // Find Monday of the current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    final completedDays = <int>{};
    for (final s in sessions) {
      if (s.endTime != null && s.startTime.isAfter(startOfWeek)) {
        completedDays.add(s.startTime.weekday);
      }
    }

    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GritTheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GritTheme.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Consistency',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                '${completedDays.length} / 7 days completed',
                style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final dayNum = index + 1;
              final isCompleted = completedDays.contains(dayNum);
              final isToday = now.weekday == dayNum;

              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? GritTheme.primary
                          : (isToday ? GritTheme.surfaceLight : Colors.transparent),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? GritTheme.primaryLight
                            : (isToday ? GritTheme.primary : GritTheme.divider),
                        width: isToday ? 2.0 : 1.0,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayLabels[index],
                      style: TextStyle(
                        color: isCompleted ? GritTheme.background : GritTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [GritTheme.accent, Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: GritTheme.accent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Make a Gym Program for Me',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Generate custom local templates matching your schedule, equipment, and strength goals.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProgramQuestionnaireScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: GritTheme.accent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('BUILD'),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesGrid(BuildContext context, WidgetRef ref, List<WorkoutTemplate> templates) {
    if (templates.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: GritTheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GritTheme.divider),
        ),
        child: const Center(
          child: Text(
            'No templates created yet.\nTap BUILD above or "+" to create one!',
            textAlign: TextAlign.center,
            style: TextStyle(color: GritTheme.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: templates.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final template = templates[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onLongPress: () => _showTemplateOptions(context, ref, template),
            onTap: () async {
              // Ask to start workout
              final start = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: GritTheme.surface,
                  title: Text('Start ${template.name}?'),
                  content: Text(template.description ?? 'Start workout from this template.'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel', style: TextStyle(color: GritTheme.textSecondary)),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                    ElevatedButton(
                      child: const Text('Start'),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ],
                ),
              );

              if (start == true && context.mounted) {
                await ref.read(activeWorkoutProvider.notifier).startWorkout(
                      name: template.name,
                      templateId: template.id,
                    );
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WorkoutLoggerScreen()),
                  );
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: GritTheme.textPrimary,
                              ),
                        ),
                        if (template.description != null && template.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            template.description!,
                            style: const TextStyle(color: GritTheme.textSecondary, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: GritTheme.textSecondary),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentHistory(BuildContext context, WidgetRef ref, List<WorkoutSession> sessions) {
    final completedSessions = sessions.where((s) => s.endTime != null).take(4).toList();

    if (completedSessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: GritTheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GritTheme.divider),
        ),
        child: const Center(
          child: Text(
            'No logged workouts yet.\nGet active and log your first session!',
            textAlign: TextAlign.center,
            style: TextStyle(color: GritTheme.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: completedSessions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = completedSessions[index];
        final formattedDate = DateFormat('EEE, MMM d • h:mm a').format(session.startTime);
        final duration = session.endTime!.difference(session.startTime);
        final durationMinutes = duration.inMinutes;

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showSessionDetails(context, ref, session),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$formattedDate • $durationMinutes min',
                          style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12),
                        ),
                        if (session.notes != null && session.notes!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            '"${session.notes}"',
                            style: const TextStyle(
                              color: GritTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _confirmDeleteSession(context, ref, session),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTemplateOptions(BuildContext context, WidgetRef ref, WorkoutTemplate template) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GritTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Delete Template', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: GritTheme.surface,
                    title: const Text('Delete Template?'),
                    content: const Text('This will delete this template permanently. Your workout history will not be affected.'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                        child: const Text('Delete'),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(databaseProvider).deleteTemplate(template.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSession(BuildContext context, WidgetRef ref, WorkoutSession session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GritTheme.surface,
        title: const Text('Delete Workout Log?'),
        content: const Text('This will delete this logged session permanently. This cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(databaseProvider).deleteWorkoutSession(session.id);
    }
  }

  void _showSessionDetails(BuildContext context, WidgetRef ref, WorkoutSession session) async {
    final sets = await ref.read(databaseProvider).getSetsForSession(session.id);
    final exercises = await ref.read(databaseProvider).getAllExercises();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GritTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        // Group sets by exercise
        final groupedSets = <int, List<ExerciseSet>>{};
        for (final s in sets) {
          groupedSets.putIfAbsent(s.exerciseId, () => []).add(s);
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(color: GritTheme.divider, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    session.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(session.startTime),
                    style: const TextStyle(color: GritTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  if (session.notes != null && session.notes!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: GritTheme.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GritTheme.divider),
                      ),
                      child: Text(
                        session.notes!,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: groupedSets.length,
                      itemBuilder: (context, index) {
                        final entry = groupedSets.entries.elementAt(index);
                        final exerciseId = entry.key;
                        final exerciseSets = entry.value;
                        final exercise = exercises.firstWhere((e) => e.id == exerciseId);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                exercise.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(3),
                                2: FlexColumnWidth(3),
                                3: FlexColumnWidth(2),
                              },
                              children: [
                                const TableRow(
                                  children: [
                                    Text('Set', style: TextStyle(color: GritTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                    Text('Weight', style: TextStyle(color: GritTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                    Text('Reps', style: TextStyle(color: GritTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                    Text('Type', style: TextStyle(color: GritTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                ...List.generate(exerciseSets.length, (idx) {
                                  final set = exerciseSets[idx];
                                  return TableRow(
                                    children: [
                                      Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('${idx + 1}')),
                                      Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('${set.weight} lbs')),
                                      Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('${set.reps}')),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        child: Text(
                                          set.setType.name,
                                          style: TextStyle(
                                            color: set.setType == SetType.Normal
                                                ? GritTheme.textPrimary
                                                : (set.setType == SetType.Warmup
                                                    ? Colors.amberAccent
                                                    : Colors.redAccent),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                            const Divider(height: 24),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateTemplateDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final allExercises = await ref.read(databaseProvider).getAllExercises();
    final selectedExercises = <Exercise>[];

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: GritTheme.surface,
          title: const Text('Create Custom Template'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Template Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description (Optional)'),
                ),
                const SizedBox(height: 16),
                const Text('Select Exercises:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    border: Border.all(color: GritTheme.divider),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    itemCount: allExercises.length,
                    itemBuilder: (context, index) {
                      final ex = allExercises[index];
                      final isSelected = selectedExercises.any((e) => e.id == ex.id);
                      return CheckboxListTile(
                        title: Text(ex.name),
                        subtitle: Text(ex.targetMuscle.name, style: const TextStyle(fontSize: 11)),
                        value: isSelected,
                        activeColor: GritTheme.primary,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              selectedExercises.add(ex);
                            } else {
                              selectedExercises.removeWhere((e) => e.id == ex.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: GritTheme.textSecondary)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Create'),
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                if (selectedExercises.isEmpty) return;

                await ref.read(databaseProvider).createTemplate(
                      nameController.text.trim(),
                      descController.text.trim(),
                      selectedExercises.map((e) => e.id).toList(),
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
