import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/database.dart';
import '../providers/database_provider.dart';
import 'theme.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _isLoading = true;
  List<WorkoutSession> _sessions = [];
  List<Exercise> _exercises = [];
  
  // Dynamic 1RM Progression selector
  Exercise? _selectedExercise;
  List<Map<String, dynamic>> _selectedExChartData = [];

  // Metrics
  Map<String, int> _muscleGroupCounts = {};
  List<int> _weeklyFrequency = []; // Workouts completed in each of the last 6 weeks (index 0 = 5 weeks ago, index 5 = this week)

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    final db = ref.read(databaseProvider);
    final sessions = await db.getAllWorkoutSessions();
    final completedSessions = sessions.where((s) => s.endTime != null).toList();
    final exercises = await db.getAllExercises();

    // 1. Calculate muscle group counts (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentSessions = completedSessions.where((s) => s.startTime.isAfter(thirtyDaysAgo)).toList();

    final Map<String, int> muscleCounts = {};
    for (final session in recentSessions) {
      final sets = await db.getSetsForSession(session.id);
      for (final s in sets) {
        final ex = exercises.firstWhere((e) => e.id == s.exerciseId, orElse: () => exercises.first);
        final muscleName = ex.targetMuscle.name;
        muscleCounts[muscleName] = (muscleCounts[muscleName] ?? 0) + 1;
      }
    }

    // 2. Calculate weekly frequency (last 6 weeks)
    final List<int> freq = List.filled(6, 0);
    final now = DateTime.now();
    for (final session in completedSessions) {
      final diffDays = now.difference(session.startTime).inDays;
      final weekIdx = 5 - (diffDays / 7).floor();
      if (weekIdx >= 0 && weekIdx < 6) {
        freq[weekIdx]++;
      }
    }

    setState(() {
      _sessions = completedSessions;
      _exercises = exercises;
      _muscleGroupCounts = muscleCounts;
      _weeklyFrequency = freq;
      _isLoading = false;
    });

    if (exercises.isNotEmpty) {
      _onExerciseChanged(exercises.first);
    }
  }

  Future<void> _onExerciseChanged(Exercise? ex) async {
    if (ex == null) return;
    
    final db = ref.read(databaseProvider);
    final sets = await db.getAllSetsForExercise(ex.id);

    // Group sets by session
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

    chartPoints.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    setState(() {
      _selectedExercise = ex;
      _selectedExChartData = chartPoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadAnalyticsData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Overview Numbers
                      _buildOverviewGrid(),
                      const SizedBox(height: 24),

                      // Weekly Frequency
                      Text(
                        'Weekly Workout Frequency',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'Outfit'),
                      ),
                      const SizedBox(height: 12),
                      _buildFrequencyBarChart(),
                      const Divider(height: 40),

                      // Muscle Split Pie Chart
                      Text(
                        'Muscle Group Volume (Last 30 Days)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'Outfit'),
                      ),
                      const SizedBox(height: 12),
                      _buildMusclePieChart(),
                      const Divider(height: 40),

                      // Exercise Progression Selector & Line Chart
                      Text(
                        'Exercise 1RM Progression',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'Outfit'),
                      ),
                      const SizedBox(height: 8),
                      _buildExercise1RMProgressor(),
                      const SizedBox(height: 60), // padding bottom
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildOverviewGrid() {
    final totalWorkouts = _sessions.length;
    double avgDuration = 0;
    if (_sessions.isNotEmpty) {
      final totalMinutes = _sessions
          .map((s) => s.endTime!.difference(s.startTime).inMinutes)
          .reduce((a, b) => a + b);
      avgDuration = totalMinutes / _sessions.length;
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Workouts',
            '$totalWorkouts',
            Icons.fitness_center,
            GritTheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Avg. Duration',
            '${avgDuration.toStringAsFixed(0)} min',
            Icons.timer_outlined,
            GritTheme.accent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GritTheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GritTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, fontFamily: 'Outfit'),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyBarChart() {
    if (_sessions.isEmpty) {
      return _buildEmptyStateCard('No workout sessions logged yet.');
    }

    return Container(
      height: 180,
      padding: const EdgeInsets.only(right: 20, left: 10, top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: GritTheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GritTheme.divider),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (_weeklyFrequency.reduce((a, b) => a > b ? a : b) + 1).toDouble(),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  if (value == value.toInt().toDouble()) {
                    return Text('${value.toInt()}', style: const TextStyle(color: GritTheme.textSecondary, fontSize: 10));
                  }
                  return const SizedBox();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < 6) {
                    final label = idx == 5 ? 'This Wk' : '${5 - idx}w ago';
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(label, style: const TextStyle(color: GritTheme.textSecondary, fontSize: 9)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(6, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: _weeklyFrequency[index].toDouble(),
                  color: GritTheme.primary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                )
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMusclePieChart() {
    if (_muscleGroupCounts.isEmpty) {
      return _buildEmptyStateCard('Log sets in the past 30 days to see muscle split.');
    }

    final totalSets = _muscleGroupCounts.values.reduce((a, b) => a + b);
    final List<Color> colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent.shade700,
      Colors.yellow.shade700,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.tealAccent.shade700,
      Colors.pinkAccent,
      Colors.indigoAccent,
      Colors.cyanAccent,
    ];

    int colorIdx = 0;
    final List<PieChartSectionData> sections = [];
    final List<Widget> legendItems = [];

    _muscleGroupCounts.forEach((muscle, count) {
      final percent = (count / totalSets) * 100;
      final color = colors[colorIdx % colors.length];
      colorIdx++;

      sections.add(
        PieChartSectionData(
          color: color,
          value: count.toDouble(),
          title: '${percent.toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      );

      legendItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('$muscle ($count sets)', style: const TextStyle(fontSize: 12, color: GritTheme.textSecondary)),
            ],
          ),
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GritTheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GritTheme.divider),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: legendItems,
          ),
        ],
      ),
    );
  }

  Widget _buildExercise1RMProgressor() {
    if (_exercises.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<Exercise>(
          initialValue: _selectedExercise,
          dropdownColor: GritTheme.surface,
          decoration: const InputDecoration(labelText: 'Select Exercise'),
          items: _exercises
              .map((ex) => DropdownMenuItem(value: ex, child: Text(ex.name)))
              .toList(),
          onChanged: _onExerciseChanged,
        ),
        const SizedBox(height: 16),
        _build1RMProgressionChart(),
      ],
    );
  }

  Widget _build1RMProgressionChart() {
    if (_selectedExChartData.length < 2) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: GritTheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GritTheme.divider),
        ),
        child: const Center(
          child: Text(
            'Log at least 2 sessions for this exercise to view progression.',
            textAlign: TextAlign.center,
            style: TextStyle(color: GritTheme.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    final spots = List.generate(_selectedExChartData.length, (index) {
      return FlSpot(index.toDouble(), _selectedExChartData[index]['1rm'] as double);
    });

    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 5;
    if (minY < 0) minY = 0;
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5;

    return Container(
      height: 180,
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
                  if (idx >= 0 && idx < _selectedExChartData.length) {
                    if (idx == 0 || idx == _selectedExChartData.length - 1 || (_selectedExChartData.length > 4 && idx == (_selectedExChartData.length / 2).floor())) {
                      final date = _selectedExChartData[idx]['date'] as DateTime;
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
                reservedSize: 32,
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
                  radius: 3.5,
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

  Widget _buildEmptyStateCard(String label) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: GritTheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GritTheme.divider),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: GritTheme.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}
