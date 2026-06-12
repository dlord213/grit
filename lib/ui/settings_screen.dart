import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
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
        'exercises': exList
            .map(
              (e) => {
                'id': e.id,
                'name': e.name,
                'description': e.description,
                'targetMuscle': e.targetMuscle.name,
                'equipment': e.equipment.name,
                'isCustom': e.isCustom,
              },
            )
            .toList(),
        'templates': tmplList
            .map(
              (t) => {'id': t.id, 'name': t.name, 'description': t.description},
            )
            .toList(),
        'template_exercises': tmplExList
            .map(
              (te) => {
                'id': te.id,
                'templateId': te.templateId,
                'exerciseId': te.exerciseId,
                'sequenceOrder': te.sequenceOrder,
              },
            )
            .toList(),
        'sessions': sessList
            .map(
              (s) => {
                'id': s.id,
                'templateId': s.templateId,
                'name': s.name,
                'startTime': s.startTime.toIso8601String(),
                'endTime': s.endTime?.toIso8601String(),
                'notes': s.notes,
              },
            )
            .toList(),
        'sets': setsList
            .map(
              (s) => {
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
              },
            )
            .toList(),
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
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _resetDatabase(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GritTheme.surface,
        title: const Text(
          'Reset Database?',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: const Text(
          'This will delete all templates, custom exercises, and logged workout history. This action cannot be undone.',
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
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
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
            const SnackBar(
              content: Text('Database reset successfully!'),
              backgroundColor: GritTheme.primary,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reset failed: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: GritTheme.background,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings_rounded, color: GritTheme.primary),
            SizedBox(width: 8),
            Text('Settings'),
          ],
        ),
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
            _buildSettingsTile(
              context,
              'Reset Application',
              'Delete all data and re-seed default exercises.',
              Icons.delete_forever_outlined,
              () => _resetDatabase(context, ref),
              isDestructive: true,
            ),
            const Divider(height: 40),
            _buildSectionHeader('ABOUT'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GritTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GritTheme.divider, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            GritTheme.primaryGradient.createShader(bounds),
                        child: const Text(
                          'Grit Gym Tracker',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.flash_on_rounded, color: GritTheme.primary, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: GritTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'An offline-first, privacy-respecting gym progressive overload logger designed for powerlifters and bodybuilders.',
                    style: TextStyle(
                      color: GritTheme.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
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
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w800,
        fontSize: 13,
        color: GritTheme.primary,
        letterSpacing: 1.0,
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
    final color = isDestructive ? Colors.redAccent : GritTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: GritTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDestructive
                ? Colors.redAccent.withValues(alpha: 0.2)
                : GritTheme.divider,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isDestructive
                          ? Colors.redAccent
                          : GritTheme.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: GritTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
