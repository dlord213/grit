import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../database/database.dart';
import '../models/enums.dart';
import '../providers/database_provider.dart';
import 'theme.dart';
import 'exercise_detail_screen.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  String _searchQuery = '';
  TargetMuscle? _selectedMuscle;
  Equipment? _selectedEquipment;

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesStreamProvider);

    return Scaffold(
      backgroundColor: GritTheme.background,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center_rounded, color: GritTheme.primary),
            SizedBox(width: 8),
            Text('Exercise Library'),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => _showCreateCustomExerciseDialog(context),
            child: Container(
              margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: GritTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  prefixIcon: const Icon(Icons.search, color: GritTheme.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              ),
            ),

            // Filter Chips Scrollable Bar
            _buildFilters(),

            // Exercise List
            Expanded(
              child: exercisesAsync.when(
                data: (exercises) {
                  final filtered = exercises.where((ex) {
                    final matchQuery = ex.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchMuscle = _selectedMuscle == null || ex.targetMuscle == _selectedMuscle;
                    final matchEquip = _selectedEquipment == null || ex.equipment == _selectedEquipment;
                    return matchQuery && matchMuscle && matchEquip;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No exercises found matching your filters.',
                        style: TextStyle(color: GritTheme.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final ex = filtered[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: GritTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: GritTheme.divider, width: 1),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: GritTheme.textPrimary)),
                          subtitle: Text('${ex.targetMuscle.name} • ${ex.equipment.name}', style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                          trailing: ex.isCustom
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: GritTheme.accentGradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('CUSTOM', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                                )
                              : const Icon(Icons.chevron_right_rounded, size: 18, color: GritTheme.textSecondary),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: ex))),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error loading exercises: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        // Muscles Horizontal list
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('All Muscles'),
                  selected: _selectedMuscle == null,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMuscle = null);
                  },
                ),
              ),
              ...TargetMuscle.values.map((muscle) {
                final isSelected = _selectedMuscle == muscle;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(muscle.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedMuscle = selected ? muscle : null;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Equipment Horizontal list
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('All Equipment'),
                  selected: _selectedEquipment == null,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedEquipment = null);
                  },
                ),
              ),
              ...Equipment.values.map((equip) {
                final isSelected = _selectedEquipment == equip;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(equip.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedEquipment = selected ? equip : null;
                      });
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showCreateCustomExerciseDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    TargetMuscle muscle = TargetMuscle.Chest;
    Equipment equip = Equipment.Dumbbell;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.fitness_center_rounded, color: GritTheme.primary),
              SizedBox(width: 8),
              Text('New Exercise'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Exercise Name *'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TargetMuscle>(
                  initialValue: muscle,
                  decoration: const InputDecoration(labelText: 'Target Muscle'),
                  dropdownColor: GritTheme.surface,
                  items: TargetMuscle.values
                      .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => muscle = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Equipment>(
                  initialValue: equip,
                  decoration: const InputDecoration(labelText: 'Equipment'),
                  dropdownColor: GritTheme.surface,
                  items: Equipment.values
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => equip = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Instructions / Description (Optional)'),
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
              child: const Text('Save'),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final companion = ExercisesCompanion.insert(
                  name: name,
                  description: Value(descController.text.trim()),
                  targetMuscle: muscle,
                  equipment: equip,
                  isCustom: const Value(true),
                );

                await ref.read(databaseProvider).insertExercise(companion);
                
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
