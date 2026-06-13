import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';
import 'theme.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  List<ExerciseSet> _historicalSets = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _chartData =
      []; // list of { 'date': DateTime, '1rm': double }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final db = ref.read(databaseProvider);
    final sets = await db.getAllSetsForExercise(widget.exercise.id);

    // Group sets by session to find max 1RM per session
    final Map<int, List<ExerciseSet>> groupedBySession = {};
    for (final s in sets) {
      groupedBySession.putIfAbsent(s.sessionId, () => []).add(s);
    }

    final List<Map<String, dynamic>> chartPoints = [];

    for (final entry in groupedBySession.entries) {
      double max1RM = 0;
      DateTime? sessionTime;
      for (final s in entry.value) {
        sessionTime = s.timestamp;
        if (s.reps > 0 && s.weight > 0) {
          double oneRepMax = s.weight;
          if (s.reps > 1) {
            oneRepMax = s.weight / (1.0278 - (0.0278 * s.reps));
          }
          if (oneRepMax > max1RM) {
            max1RM = oneRepMax;
          }
        }
      }

      if (max1RM > 0 && sessionTime != null) {
        chartPoints.add({'date': sessionTime, '1rm': max1RM});
      }
    }

    // Sort chart points by date
    chartPoints.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );

    setState(() {
      _historicalSets = sets.reversed.toList(); // Newest sets first
      _chartData = chartPoints;
      _isLoading = false;
    });
  }

  double _calculateSet1RM(ExerciseSet set) {
    if (set.reps <= 0 || set.weight <= 0) return 0;
    if (set.reps == 1) return set.weight;
    return set.weight / (1.0278 - (0.0278 * set.reps));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.exercise.name),
        actions: [
          if (widget.exercise.isCustom)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: GritTheme.danger,
              ),
              onPressed: () => _confirmDeleteExercise(context),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.exercise.imageUrl != null &&
                        widget.exercise.imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: widget.exercise.imageUrl!,
                          height: 320,
                          width: 320,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Exercise Info Badges
                    Row(
                      children: [
                        _buildBadge(
                          widget.exercise.targetMuscle.name,
                          GritTheme.primary,
                        ),
                        const SizedBox(width: 8),
                        _buildBadge(
                          widget.exercise.equipment.name,
                          GritTheme.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (widget.exercise.description != null &&
                        widget.exercise.description!.isNotEmpty) ...[
                      _buildSectionLabel(
                        'Instructions',
                        Icons.description_rounded,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          widget.exercise.description!,
                          style: const TextStyle(
                            color: GritTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    _buildSectionLabel(
                      '1RM Progression (lbs)',
                      Icons.trending_up_rounded,
                    ),
                    const SizedBox(height: 12),
                    _build1RMChart(),
                    const SizedBox(height: 24),
                    _buildSectionLabel(
                      'Workout History',
                      Icons.history_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildHistoryList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: GritTheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          fontFamily: 'Rubik',
        ),
      ),
    );
  }

  Widget _build1RMChart() {
    if (_chartData.length < 2) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Center(
          child: Text(
            'Log at least 2 sessions to see progression chart.',
            textAlign: TextAlign.center,
            style: TextStyle(color: GritTheme.textSecondary),
          ),
        ),
      );
    }

    final spots = List.generate(_chartData.length, (index) {
      return FlSpot(index.toDouble(), _chartData[index]['1rm'] as double);
    });

    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 5;
    if (minY < 0) minY = 0;
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5;

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 24, left: 8, top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < _chartData.length) {
                    // Show date labels for start, mid, end points
                    if (idx == 0 ||
                        idx == _chartData.length - 1 ||
                        (_chartData.length > 4 &&
                            idx == (_chartData.length / 2).floor())) {
                      final date = _chartData[idx]['date'] as DateTime;
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          DateFormat('MM/dd').format(date),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(
                        color: GritTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: GritTheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: GritTheme.primaryLight,
                      strokeWidth: 1.5,
                      strokeColor: GritTheme.primary,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: GritTheme.primary.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_historicalSets.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: const Center(
          child: Text(
            'No logged sets for this exercise yet.',
            style: TextStyle(color: GritTheme.textSecondary),
          ),
        ),
      );
    }

    // Group historical sets by date
    final Map<String, List<ExerciseSet>> groupedByDate = {};
    for (final s in _historicalSets) {
      final key = DateFormat('EEEE, MMMM d, yyyy').format(s.timestamp);
      groupedByDate.putIfAbsent(key, () => []).add(s);
    }

    // Pre-compute per-date max 1RM (chronological order: oldest first)
    final dateKeys = groupedByDate.keys.toList();
    final List<String> chronologicalDates = dateKeys.reversed.toList();
    final Map<String, double> dateMax1RM = {};
    for (final key in chronologicalDates) {
      double max1RM = 0;
      for (final s in groupedByDate[key]!) {
        final rm = _calculateSet1RM(s);
        if (rm > max1RM) max1RM = rm;
      }
      dateMax1RM[key] = max1RM;
    }

    // All-time best across all sessions
    double allTimeBest = 0;
    for (final rm in dateMax1RM.values) {
      if (rm > allTimeBest) allTimeBest = rm;
    }

    // Determine LEVEL UP dates: sessions that set a new all-time record
    final Set<String> levelUpDates = {};
    double bestSoFar = 0;
    for (final key in chronologicalDates) {
      final rm = dateMax1RM[key]!;
      if (rm > bestSoFar && bestSoFar > 0) {
        levelUpDates.add(key);
      }
      if (rm > bestSoFar) bestSoFar = rm;
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedByDate.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final dateKey = groupedByDate.keys.elementAt(index);
        final sets = groupedByDate[dateKey]!;
        final sessionMax1RM = dateMax1RM[dateKey]!;
        final isLevelUp = levelUpDates.contains(dateKey);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dateKey,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: GritTheme.primary,
                      ),
                    ),
                  ),
                  if (isLevelUp) _buildLevelUpBadge(),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(sets.length, (idx) {
                final s = sets[idx];
                final est1RM = _calculateSet1RM(s);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Set ${sets.length - idx}:  ${s.weight} lbs  x  ${s.reps} reps',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '1RM Est: ${est1RM.toStringAsFixed(0)} lbs',
                        style: const TextStyle(
                          color: GritTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (allTimeBest > 0 && chronologicalDates.length > 1)
                _buildMilestoneBar(sessionMax1RM, allTimeBest),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestoneBar(double sessionMax1RM, double allTimeBest1RM) {
    if (allTimeBest1RM <= 0) return const SizedBox.shrink();

    final position = (sessionMax1RM / allTimeBest1RM).clamp(0.0, 1.0);

    String zoneLabel;
    Color zoneColor;
    if (position >= 0.95) {
      zoneLabel = 'Elite';
      zoneColor = GritTheme.milestoneZone5;
    } else if (position >= 0.85) {
      zoneLabel = 'Advanced';
      zoneColor = GritTheme.milestoneZone4;
    } else if (position >= 0.70) {
      zoneLabel = 'Intermediate';
      zoneColor = GritTheme.milestoneZone3;
    } else if (position >= 0.50) {
      zoneLabel = 'Novice';
      zoneColor = GritTheme.milestoneZone2;
    } else {
      zoneLabel = 'Starter';
      zoneColor = GritTheme.milestoneZone1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        SizedBox(
          height: 20,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth - 24;
              final markerX = position * barWidth;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Segment bar
                  Positioned(
                    left: 0,
                    right: 24,
                    top: 3,
                    child: Row(
                      children: [
                        _buildSegment(barWidth, GritTheme.milestoneZone1),
                        const SizedBox(width: 2),
                        _buildSegment(barWidth, GritTheme.milestoneZone2),
                        const SizedBox(width: 2),
                        _buildSegment(barWidth, GritTheme.milestoneZone3),
                        const SizedBox(width: 2),
                        _buildSegment(barWidth, GritTheme.milestoneZone4),
                        const SizedBox(width: 2),
                        _buildSegment(barWidth, GritTheme.milestoneZone5),
                      ],
                    ),
                  ),
                  // Marker
                  Positioned(
                    left: markerX.clamp(0.0, barWidth - 10),
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: zoneColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: zoneColor.withValues(alpha: 0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Flag
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(
                      Icons.flag_rounded,
                      size: 18,
                      color: GritTheme.accentWarm,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: zoneColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                zoneLabel,
                style: TextStyle(
                  color: zoneColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Rubik',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Session 1RM: ${sessionMax1RM.toStringAsFixed(0)} lbs',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 11,
                fontFamily: 'Rubik',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSegment(double totalWidth, Color color) {
    return Expanded(
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildLevelUpBadge() {
    return _LevelUpBadge();
  }

  void _confirmDeleteExercise(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Delete Custom Exercise?'),
        content: const Text(
          'Are you sure you want to delete this custom exercise? All historical logs and data for this exercise will be deleted.',
        ),
        actions: [
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: GritTheme.textSecondary),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GritTheme.danger,
              foregroundColor: GritTheme.onPrimary,
            ),
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(databaseProvider).deleteExercise(widget.exercise.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}

class _LevelUpBadge extends StatefulWidget {
  const _LevelUpBadge();

  @override
  State<_LevelUpBadge> createState() => _LevelUpBadgeState();
}

class _LevelUpBadgeState extends State<_LevelUpBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD166), Color(0xFFFF8E53)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: GritTheme.accentWarm.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              'LEVEL UP!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                fontFamily: 'Rubik',
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
