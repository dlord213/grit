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
import 'avatar/avatar_widget.dart';
import 'common/biometric_card.dart';
import 'profile_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesStreamProvider);
    final sessionsAsync = ref.watch(sessionsStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: GritTheme.primary,
          onRefresh: () async {},
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, ref),
                const SizedBox(height: 20),
                sessionsAsync.when(
                  data: (sessions) => _buildStreakTracker(context, sessions),
                  loading: () => const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, s) => const SizedBox(),
                ),
                const SizedBox(height: 16),
                _buildProgramBanner(context),
                const SizedBox(height: 16),
                templatesAsync.when(
                  data: (templates) => templates.isEmpty
                      ? _buildNoTemplatesPrompt(context)
                      : _buildStartWorkoutButton(context, ref),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  context,
                  'Workout Templates',
                  Icons.fitness_center_rounded,
                ),
                const SizedBox(height: 12),
                templatesAsync.when(
                  data: (templates) =>
                      _buildTemplatesGrid(context, ref, templates),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error: $e'),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle(
                  context,
                  'Recent Workouts',
                  Icons.calendar_month_rounded,
                ),
                const SizedBox(height: 12),
                sessionsAsync.when(
                  data: (sessions) =>
                      _buildRecentHistory(context, ref, sessions),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error: $e'),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: const AvatarHeadDisplay(size: 44),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'GRIT',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: GritTheme.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.flash_on_rounded,
                      color: GritTheme.primary,
                      size: 24,
                    ),
                  ],
                ),
                Text(
                  'Gym Tracker',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 13,
                    color: GritTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _showCreateTemplateDialog(context, ref),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GritTheme.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: GritTheme.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: GritTheme.onPrimary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: GritTheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakTracker(
    BuildContext context,
    List<WorkoutSession> sessions,
  ) {
    final now = DateTime.now();
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: GritTheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: GritTheme.accentWarm,
                    size: 20,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Weekly Streak',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: GritTheme.accentWarm.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${completedDays.length}/7 days',
                  style: const TextStyle(
                    color: GritTheme.accentWarm,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? GritTheme.primary
                          : (isToday
                                ? GritTheme.surfaceLight
                                : Theme.of(context).scaffoldBackgroundColor),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? GritTheme.primaryDark
                            : (isToday
                                  ? GritTheme.primary
                                  : Theme.of(context).dividerColor),
                        width: isToday ? 2.5 : 1.5,
                      ),
                      boxShadow: isCompleted
                          ? [
                              BoxShadow(
                                color: GritTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isCompleted ? '✓' : dayLabels[index],
                      style: TextStyle(
                        color: isCompleted
                            ? GritTheme.onPrimary
                            : (isToday
                                  ? GritTheme.primary
                                  : GritTheme.textSecondary),
                        fontWeight: FontWeight.w800,
                        fontSize: isCompleted ? 14 : 13,
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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProgramQuestionnaireScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GritTheme.accentViolet,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: GritTheme.accent.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: GritTheme.onPrimary,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Build My Program',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: GritTheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Generate a custom plan for your schedule & goals',
                    style: TextStyle(
                      fontSize: 12,
                      color: GritTheme.onPrimary.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: GritTheme.onPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'BUILD',
                style: TextStyle(
                  color: GritTheme.accentViolet,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartWorkoutButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await ref
            .read(activeWorkoutProvider.notifier)
            .startWorkout(name: 'Empty Workout');
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkoutLoggerScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: GritTheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: GritTheme.primary.withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow_rounded,
              color: GritTheme.onPrimary,
              size: 26,
            ),
            SizedBox(width: 8),
            Text(
              'START EMPTY WORKOUT',
              style: TextStyle(
                fontFamily: 'Rubik',
                color: GritTheme.onPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTemplatesPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: GritTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GritTheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            color: GritTheme.primary,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            'No templates yet',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: GritTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a workout template first,\nthen start your workout from it',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GritTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_upward_rounded,
                color: GritTheme.primary,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                'Use + or Build My Program above',
                style: TextStyle(
                  color: GritTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplatesGrid(
    BuildContext context,
    WidgetRef ref,
    List<WorkoutTemplate> templates,
  ) {
    if (templates.isEmpty) {
      return _buildEmptyState(
        'No templates yet!\nTap BUILD or + to create one',
        GritTheme.accent,
        Icons.create_rounded,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: templates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final template = templates[index];
        final colors = [
          GritTheme.primary,
          GritTheme.accent,
          GritTheme.accentWarm,
          GritTheme.success,
        ];
        final color = colors[index % colors.length];
        return GestureDetector(
          onLongPress: () => _showTemplateOptions(context, ref, template),
          onTap: () async {
            final start = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Start ${template.name}?'),
                content: Text(
                  template.description ?? 'Start workout from this template.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Start'),
                  ),
                ],
              ),
            );
            if (start == true && context.mounted) {
              await ref
                  .read(activeWorkoutProvider.notifier)
                  .startWorkout(name: template.name, templateId: template.id);
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkoutLoggerScreen(),
                  ),
                );
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border(left: BorderSide(color: color, width: 4)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.directions_run_rounded,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: GritTheme.textPrimary,
                          ),
                        ),
                        if (template.description != null &&
                            template.description!.isNotEmpty)
                          Text(
                            template.description!,
                            style: const TextStyle(
                              color: GritTheme.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: color.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentHistory(
    BuildContext context,
    WidgetRef ref,
    List<WorkoutSession> sessions,
  ) {
    final completedSessions = sessions
        .where((s) => s.endTime != null)
        .take(4)
        .toList();
    if (completedSessions.isEmpty) {
      return _buildEmptyState(
        'No logged workouts yet.\nGo crush it!',
        GritTheme.success,
        Icons.fitness_center_rounded,
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: completedSessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final session = completedSessions[index];
        final formattedDate = DateFormat(
          'EEE, MMM d • h:mm a',
        ).format(session.startTime);
        final durationMinutes = session.endTime!
            .difference(session.startTime)
            .inMinutes;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: GritTheme.primary.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: GritTheme.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: GritTheme.success,
                size: 20,
              ),
            ),
            title: Text(
              session.name,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: GritTheme.textPrimary,
              ),
            ),
            subtitle: Text(
              '$formattedDate • $durationMinutes min',
              style: const TextStyle(
                color: GritTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: GritTheme.success.withValues(alpha: 0.6),
            ),
            onTap: () => _showSessionDetails(context, ref, session),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GritTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTemplateOptions(
    BuildContext context,
    WidgetRef ref,
    WorkoutTemplate template,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_rounded,
                color: GritTheme.danger,
              ),
              title: const Text(
                'Delete Template',
                style: TextStyle(
                  color: GritTheme.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Template?'),
                    content: const Text(
                      'This will delete this template permanently.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GritTheme.danger,
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
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

  void _confirmDeleteSession(
    BuildContext context,
    WidgetRef ref,
    WorkoutSession session,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Workout Log?'),
        content: const Text(
          'This will permanently delete this logged session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GritTheme.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(databaseProvider).deleteWorkoutSession(session.id);
    }
  }

  void _showSessionDetails(
    BuildContext context,
    WidgetRef ref,
    WorkoutSession session,
  ) async {
    final sets = await ref.read(databaseProvider).getSetsForSession(session.id);
    final exercises = await ref.read(databaseProvider).getAllExercises();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        final groupedSets = <int, List<ExerciseSet>>{};
        for (final s in sets) {
          groupedSets.putIfAbsent(s.exerciseId, () => []).add(s);
        }
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  session.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(session.startTime),
                  style: const TextStyle(
                    color: GritTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: groupedSets.length,
                    itemBuilder: (context, index) {
                      final entry = groupedSets.entries.elementAt(index);
                      final exercise = exercises.firstWhere(
                        (e) => e.id == entry.key,
                      );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              exercise.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
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
                                  Text(
                                    'Set',
                                    style: TextStyle(
                                      color: GritTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Weight',
                                    style: TextStyle(
                                      color: GritTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Reps',
                                    style: TextStyle(
                                      color: GritTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Type',
                                    style: TextStyle(
                                      color: GritTheme.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              ...List.generate(entry.value.length, (idx) {
                                final set = entry.value[idx];
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Text('${idx + 1}'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Text('${set.weight} lbs'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Text('${set.reps}'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Text(
                                        set.setType.name,
                                        style: TextStyle(
                                          color: set.setType == SetType.Normal
                                              ? GritTheme.textPrimary
                                              : GritTheme.danger,
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
          ),
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.create_rounded, color: GritTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'Create Template',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Template Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Exercises:',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: allExercises.length,
                      itemBuilder: (context, index) {
                        final ex = allExercises[index];
                        final isSelected = selectedExercises.any(
                          (e) => e.id == ex.id,
                        );
                        return CheckboxListTile(
                          title: Text(
                            ex.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                          subtitle: Text(
                            ex.targetMuscle.name,
                            style: const TextStyle(fontSize: 11),
                          ),
                          value: isSelected,
                          onChanged: (val) => setState(() {
                            if (val == true)
                              selectedExercises.add(ex);
                            else
                              selectedExercises.removeWhere(
                                (e) => e.id == ex.id,
                              );
                          }),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty ||
                              selectedExercises.isEmpty)
                            return;
                          await ref
                              .read(databaseProvider)
                              .createTemplate(
                                nameController.text.trim(),
                                descController.text.trim(),
                                selectedExercises.map((e) => e.id).toList(),
                              );
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Create'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
