import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../models/enums.dart';
import '../providers/database_provider.dart';
import 'theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      
      final exList = await db.getAllExercises();
      final tmplList = await db.select(db.workoutTemplates).get();
      final tmplExList = await db.select(db.templateExercises).get();
      final sessList = await db.select(db.workoutSessions).get();
      final setsList = await db.select(db.exerciseSets).get();

      final backup = {
        'version': 1,
        'exercises': exList.map((e) => {
          'id': e.id,
          'name': e.name,
          'description': e.description,
          'targetMuscle': e.targetMuscle.name,
          'equipment': e.equipment.name,
          'isCustom': e.isCustom,
        }).toList(),
        'templates': tmplList.map((t) => {
          'id': t.id,
          'name': t.name,
          'description': t.description,
        }).toList(),
        'template_exercises': tmplExList.map((te) => {
          'id': te.id,
          'templateId': te.templateId,
          'exerciseId': te.exerciseId,
          'sequenceOrder': te.sequenceOrder,
        }).toList(),
        'sessions': sessList.map((s) => {
          'id': s.id,
          'templateId': s.templateId,
          'name': s.name,
          'startTime': s.startTime.toIso8601String(),
          'endTime': s.endTime?.toIso8601String(),
          'notes': s.notes,
        }).toList(),
        'sets': setsList.map((s) => {
          'id': s.id,
          'sessionId': s.sessionId,
          'exerciseId': s.exerciseId,
          'weight': s.weight,
          'reps': s.reps,
          'setType': s.setType.name,
          'restTime': s.restTime,
          'isCompleted': s.isCompleted,
          'timestamp': s.timestamp.toIso8601String(),
          'sequenceOrder': s.sequenceOrder,
        }).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
      
      // Save locally to a temp file and share
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/grit_backup.json');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Grit Gym Tracker Backup',
        subject: 'Grit Backup',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final Map<String, dynamic> backup = json.decode(content);

      if (backup['version'] != 1) {
        throw Exception('Unsupported backup version.');
      }

      final db = ref.read(databaseProvider);

      await db.transaction(() async {
        // 1. Fetch current exercises to prevent duplicates
        final existingExercises = await db.getAllExercises();
        final Map<int, int> exerciseIdMap = {};

        final List<dynamic> jsonExercises = backup['exercises'] ?? [];
        for (final je in jsonExercises) {
          final oldId = je['id'] as int;
          final name = je['name'] as String;
          final description = je['description'] as String?;
          final muscle = TargetMuscle.fromName(je['targetMuscle'] as String);
          final equip = Equipment.fromName(je['equipment'] as String);
          final isCustom = je['isCustom'] as bool;

          // Find if duplicate exists
          final duplicate = existingExercises.firstWhere(
            (e) => e.name.toLowerCase() == name.toLowerCase(),
            orElse: () => const Exercise(
              id: -1,
              name: '',
              targetMuscle: TargetMuscle.Chest,
              equipment: Equipment.Barbell,
              isCustom: false,
            ),
          );

          if (duplicate.id != -1) {
            exerciseIdMap[oldId] = duplicate.id;
          } else {
            final newId = await db.insertExercise(
              ExercisesCompanion.insert(
                name: name,
                description: drift.Value(description),
                targetMuscle: muscle,
                equipment: equip,
                isCustom: drift.Value(isCustom),
              ),
            );
            exerciseIdMap[oldId] = newId;
          }
        }

        // 2. Import Workout Templates
        final Map<int, int> templateIdMap = {};
        final List<dynamic> jsonTemplates = backup['templates'] ?? [];
        for (final jt in jsonTemplates) {
          final oldId = jt['id'] as int;
          final name = jt['name'] as String;
          final description = jt['description'] as String?;

          final newId = await db.into(db.workoutTemplates).insert(
            WorkoutTemplatesCompanion.insert(
              name: name,
              description: drift.Value(description),
            ),
          );
          templateIdMap[oldId] = newId;
        }

        // 3. Import Template Exercises
        final List<dynamic> jsonTemplateExs = backup['template_exercises'] ?? [];
        for (final jte in jsonTemplateExs) {
          final oldTmplId = jte['templateId'] as int;
          final oldExId = jte['exerciseId'] as int;
          final seq = jte['sequenceOrder'] as int;

          final newTmplId = templateIdMap[oldTmplId];
          final newExId = exerciseIdMap[oldExId];

          if (newTmplId != null && newExId != null) {
            await db.into(db.templateExercises).insert(
              TemplateExercisesCompanion.insert(
                templateId: newTmplId,
                exerciseId: newExId,
                sequenceOrder: seq,
              ),
            );
          }
        }

        // 4. Import Workout Sessions
        final Map<int, int> sessionIdMap = {};
        final List<dynamic> jsonSessions = backup['sessions'] ?? [];
        for (final js in jsonSessions) {
          final oldId = js['id'] as int;
          final oldTmplId = js['templateId'] as int?;
          final name = js['name'] as String;
          final startTime = DateTime.parse(js['startTime'] as String);
          final endTime = js['endTime'] != null ? DateTime.parse(js['endTime'] as String) : null;
          final notes = js['notes'] as String?;

          final newTmplId = oldTmplId != null ? templateIdMap[oldTmplId] : null;

          final newId = await db.into(db.workoutSessions).insert(
            WorkoutSessionsCompanion.insert(
              templateId: drift.Value(newTmplId),
              name: name,
              startTime: startTime,
              endTime: drift.Value(endTime),
              notes: drift.Value(notes),
            ),
          );
          sessionIdMap[oldId] = newId;
        }

        // 5. Import Sets
        final List<dynamic> jsonSets = backup['sets'] ?? [];
        for (final js in jsonSets) {
          final oldSessId = js['sessionId'] as int;
          final oldExId = js['exerciseId'] as int;
          final weight = (js['weight'] as num).toDouble();
          final reps = js['reps'] as int;
          final setType = SetType.fromName(js['setType'] as String);
          final restTime = js['restTime'] as int;
          final isCompleted = js['isCompleted'] as bool;
          final timestamp = DateTime.parse(js['timestamp'] as String);
          final seq = js['sequenceOrder'] as int;

          final newSessId = sessionIdMap[oldSessId];
          final newExId = exerciseIdMap[oldExId];

          if (newSessId != null && newExId != null) {
            await db.into(db.exerciseSets).insert(
              ExerciseSetsCompanion.insert(
                sessionId: newSessId,
                exerciseId: newExId,
                weight: weight,
                reps: reps,
                setType: setType,
                restTime: drift.Value(restTime),
                isCompleted: drift.Value(isCompleted),
                timestamp: timestamp,
                sequenceOrder: seq,
              ),
            );
          }
        }
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored successfully!'), backgroundColor: GritTheme.primary),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _resetDatabase(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GritTheme.surface,
        title: const Text('Reset Database?', style: TextStyle(color: Colors.redAccent)),
        content: const Text('This will delete all templates, custom exercises, and logged workout history. This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: GritTheme.textSecondary)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Reset'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await ref.read(databaseProvider).clearDatabase();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database reset successfully!'), backgroundColor: GritTheme.primary),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reset failed: $e'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Backup and Restore Section
            _buildSectionHeader('Data Management'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              context,
              'Export Backup',
              'Share or save your logged workouts and templates.',
              Icons.backup_outlined,
              () => _exportBackup(context, ref),
            ),
            const SizedBox(height: 12),
            _buildSettingsTile(
              context,
              'Import Backup',
              'Restore your data from a previously exported JSON backup.',
              Icons.restore_outlined,
              () => _importBackup(context, ref),
            ),
            const SizedBox(height: 12),
            _buildSettingsTile(
              context,
              'Reset Application',
              'Delete all data and re-seed default exercises.',
              Icons.delete_forever_outlined,
              () => _resetDatabase(context, ref),
              isDestructive: true,
            ),
            const Divider(height: 40),
            
            // About Section
            _buildSectionHeader('About'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GritTheme.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GritTheme.divider),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Grit Gym Tracker',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(color: GritTheme.textSecondary, fontSize: 13),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'An offline-first, privacy-respecting gym progressive overload logger designed for powerlifters and bodybuilders.',
                    style: TextStyle(color: GritTheme.textSecondary, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Outfit',
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: GritTheme.primary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(
          icon,
          color: isDestructive ? Colors.redAccent : GritTheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.redAccent : GritTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: GritTheme.textSecondary, fontSize: 12),
        ),
        onTap: onTap,
      ),
    );
  }
}
