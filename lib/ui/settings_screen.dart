import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/database_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/weight_unit_provider.dart';
import '../providers/shop_provider.dart';
import 'theme.dart';
import 'profile_screen.dart';
import 'shop/shop_screen.dart';

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
            backgroundColor: GritTheme.danger,
          ),
        );
      }
    }
  }

  Future<void> _resetDatabase(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Reset Database?',
          style: TextStyle(color: GritTheme.danger),
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
              backgroundColor: GritTheme.danger,
              foregroundColor: GritTheme.onPrimary,
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
              backgroundColor: GritTheme.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            // Appearance Section
            _buildSectionHeader('APPEARANCE'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              context,
              'Profile',
              'View & edit your Grit-tar and biometrics',
              Icons.person_rounded,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildShopTile(context, ref),
            const SizedBox(height: 12),
            _buildThemeToggle(context, ref),
            const SizedBox(height: 12),
            _buildWeightUnitToggle(context, ref),
            const SizedBox(height: 8),

            const SizedBox(height: 12),
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
              'Reset Application',
              'Delete all data and re-seed default exercises.',
              Icons.delete_forever_outlined,
              () => _resetDatabase(context, ref),
              isDestructive: true,
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
        fontFamily: 'Rubik',
        fontWeight: FontWeight.w800,
        fontSize: 13,
        color: GritTheme.primary,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
      ),
      child: Row(
        children: [
          _themeOption(
            ref,
            Icons.brightness_auto_rounded,
            'System',
            ThemeMode.system,
            currentMode,
          ),
          _themeOption(
            ref,
            Icons.light_mode_rounded,
            'Light',
            ThemeMode.light,
            currentMode,
          ),
          _themeOption(
            ref,
            Icons.dark_mode_rounded,
            'Dark',
            ThemeMode.dark,
            currentMode,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightUnitToggle(BuildContext context, WidgetRef ref) {
    final currentUnit = ref.watch(weightUnitProvider);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
      ),
      child: Row(
        children: [
          _unitOption(ref, 'LBS', WeightUnit.lbs, currentUnit),
          _unitOption(ref, 'KG', WeightUnit.kg, currentUnit),
        ],
      ),
    );
  }

  Widget _unitOption(WidgetRef ref, String label, WeightUnit unit, WeightUnit current) {
    final isSelected = current == unit;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(weightUnitProvider.notifier).setUnit(unit),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? GritTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                unit == WeightUnit.lbs ? Icons.fitness_center_rounded : Icons.monitor_weight_outlined,
                size: 16,
                color: isSelected ? GritTheme.onPrimary : GritTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? GritTheme.onPrimary : GritTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeOption(
    WidgetRef ref,
    IconData icon,
    String label,
    ThemeMode mode,
    ThemeMode current,
  ) {
    final isSelected = current == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(themeModeProvider.notifier).setMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? GritTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? GritTheme.onPrimary
                    : GritTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? GritTheme.onPrimary
                      : GritTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShopTile(BuildContext context, WidgetRef ref) {
    final shopState = ref.watch(shopProvider);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ShopScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: GritTheme.accentWarm.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: GritTheme.accentWarm.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: GritTheme.accentWarm.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.store_rounded,
                color: GritTheme.accentWarm,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GRIT Shop',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  const Text(
                    'Spend GP on themes, gear & titles',
                    style: TextStyle(
                      color: GritTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: GritTheme.accentWarm.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, color: GritTheme.accentWarm, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '${shopState.gpBalance}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: GritTheme.accentWarm,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: GritTheme.accentWarm.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
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
    final color = isDestructive ? GritTheme.danger : GritTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDestructive
                ? GritTheme.danger.withValues(alpha: 0.2)
                : Theme.of(context).dividerColor,
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
                          ? GritTheme.danger
                          : Theme.of(context).colorScheme.onSurface,
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
