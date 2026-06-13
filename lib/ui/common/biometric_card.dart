import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/biometric_provider.dart';
import '../../providers/weight_unit_provider.dart';
import '../theme.dart';
import 'biometric_editor_sheet.dart';

class BiometricCard extends ConsumerWidget {
  const BiometricCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(biometricProvider);
    final unit = ref.watch(weightUnitProvider);

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
            children: [
              const Icon(Icons.monitor_weight_outlined, color: GritTheme.accent, size: 18),
              const SizedBox(width: 6),
              Text(
                'Biometrics',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 300) {
                return _buildVerticalLayout(context, ref, config, unit);
              }
              return _buildHorizontalLayout(context, ref, config, unit);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context, WidgetRef ref, dynamic config, WeightUnit unit) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            context,
            ref,
            icon: Icons.monitor_weight_outlined,
            label: 'Current',
            value: formatWeight(config.currentWeight, unit),
            color: GritTheme.primary,
            onTap: () => showBiometricEditor(context, ref, BiometricField.currentWeight),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            context,
            ref,
            icon: Icons.flag_outlined,
            label: 'Target',
            value: formatWeight(config.targetWeight, unit),
            color: GritTheme.accent,
            onTap: () => showBiometricEditor(context, ref, BiometricField.targetWeight),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricTile(
            context,
            ref,
            icon: Icons.height,
            label: 'Height',
            value: config.heightFormatted,
            color: GritTheme.success,
            onTap: () => showBiometricEditor(context, ref, BiometricField.height),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(BuildContext context, WidgetRef ref, dynamic config, WeightUnit unit) {
    return Column(
      children: [
        _buildMetricTile(
          context,
          ref,
          icon: Icons.monitor_weight_outlined,
          label: 'Current',
          value: formatWeight(config.currentWeight, unit),
          color: GritTheme.primary,
          onTap: () => showBiometricEditor(context, ref, BiometricField.currentWeight),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context,
                ref,
                icon: Icons.flag_outlined,
                label: 'Target',
                value: formatWeight(config.targetWeight, unit),
                color: GritTheme.accent,
                onTap: () => showBiometricEditor(context, ref, BiometricField.targetWeight),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                context,
                ref,
                icon: Icons.height,
                label: 'Height',
                value: config.heightFormatted,
                color: GritTheme.success,
                onTap: () => showBiometricEditor(context, ref, BiometricField.height),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
