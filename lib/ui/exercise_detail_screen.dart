import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';
import 'theme.dart';

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  final Exercise exercise;
  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  ConsumerState<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen> {
  List<ExerciseSet> _historicalSets = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _chartData = []; // list of { 'date': DateTime, '1rm': double }

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
        chartPoints.add({
          'date': sessionTime,
          '1rm': max1RM,
        });
      }
    }

    // Sort chart points by date
    chartPoints.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

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
      appBar: AppBar(
        title: Text(widget.exercise.name),
        actions: [
          if (widget.exercise.isCustom)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
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
                    // Exercise Info Badges
                    Row(
                      children: [
                        _buildBadge(widget.exercise.targetMuscle.name, GritTheme.primary),
                        const SizedBox(width: 8),
                        _buildBadge(widget.exercise.equipment.name, GritTheme.accent),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Exercise Description
                    if (widget.exercise.description != null && widget.exercise.description!.isNotEmpty) ...[
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'Outfit'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.exercise.description!,
                        style: const TextStyle(color: GritTheme.textSecondary, height: 1.4),
                      ),
                      const Divider(height: 32),
                    ],

                    // 1RM Progression Chart
                    Text(
                      '1RM Progression (lbs)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'Outfit'),
                    ),
                    const SizedBox(height: 12),
                    _build1RMChart(),
                    const Divider(height: 32),

                    // Set Logs History
                    Text(
                      'Workout History',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'Outfit'),
                    ),
                    const SizedBox(height: 12),
                    _buildHistoryList(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
      ),
    );
  }

  Widget _build1RMChart() {
    if (_chartData.length < 2) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: GritTheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GritTheme.divider),
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
        color: GritTheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GritTheme.divider),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => const FlLine(color: GritTheme.divider, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < _chartData.length) {
                    // Show date labels for start, mid, end points
                    if (idx == 0 || idx == _chartData.length - 1 || (_chartData.length > 4 && idx == (_chartData.length / 2).floor())) {
                      final date = _chartData[idx]['date'] as DateTime;
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          DateFormat('MM/dd').format(date),
                          style: const TextStyle(color: GritTheme.textSecondary, fontSize: 10),
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
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(color: GritTheme.textSecondary, fontSize: 10),
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
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
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
          color: GritTheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GritTheme.divider),
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

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedByDate.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final dateKey = groupedByDate.keys.elementAt(index);
        final sets = groupedByDate[dateKey]!;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GritTheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GritTheme.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateKey,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: GritTheme.primary),
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
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '1RM Est: ${est1RM.toStringAsFixed(0)} lbs',
                        style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteExercise(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GritTheme.surface,
        title: const Text('Delete Custom Exercise?'),
        content: const Text('Are you sure you want to delete this custom exercise? All historical logs and data for this exercise will be deleted.'),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: GritTheme.textSecondary)),
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

    if (confirm == true && context.mounted) {
      await ref.read(databaseProvider).deleteExercise(widget.exercise.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
