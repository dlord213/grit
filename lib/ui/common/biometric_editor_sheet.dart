import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/biometric_provider.dart';
import '../../providers/weight_unit_provider.dart';
import '../theme.dart';

enum BiometricField { currentWeight, targetWeight, height }

void showBiometricEditor(BuildContext context, WidgetRef ref, BiometricField field) {
  final config = ref.read(biometricProvider);
  final unit = ref.read(weightUnitProvider);
  final currentValue = switch (field) {
    BiometricField.currentWeight => config.currentWeight,
    BiometricField.targetWeight => config.targetWeight,
    BiometricField.height => config.height,
  };

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _BiometricEditorSheet(
      field: field,
      initialValue: currentValue,
      initialUnit: unit,
    ),
  );
}

class _BiometricEditorSheet extends ConsumerStatefulWidget {
  final BiometricField field;
  final double initialValue;
  final WeightUnit initialUnit;

  const _BiometricEditorSheet({
    required this.field,
    required this.initialValue,
    required this.initialUnit,
  });

  @override
  ConsumerState<_BiometricEditorSheet> createState() =>
      _BiometricEditorSheetState();
}

class _BiometricEditorSheetState extends ConsumerState<_BiometricEditorSheet> {
  late double _value;
  late bool _isKg;

  bool get _isWeight => widget.field != BiometricField.height;

  String get _label => switch (widget.field) {
    BiometricField.currentWeight => 'Current Weight',
    BiometricField.targetWeight => 'Target Weight',
    BiometricField.height => 'Height',
  };

  String get _unit => _isWeight ? (_isKg ? 'kg' : 'lbs') : 'in';

  double get _min {
    if (_isWeight) return _isKg ? 23 : 50;
    return 48;
  }

  double get _max {
    if (_isWeight) return _isKg ? 182 : 400;
    return 84;
  }

  double get _step {
    if (_isWeight) return _isKg ? 0.5 : 1;
    return 0.5;
  }

  String _formatValue(double val) {
    if (!_isWeight) {
      final totalInches = val.round();
      final feet = totalInches ~/ 12;
      final inches = totalInches % 12;
      return "$feet'$inches\"";
    }
    return '${val.round()} $_unit';
  }

  double _lbsToDisplay(double lbs) {
    if (_isWeight && _isKg) return lbsToKg(lbs);
    return lbs;
  }

  double _displayToLbs(double displayVal) {
    if (_isWeight && _isKg) return kgToLbs(displayVal);
    return displayVal;
  }

  @override
  void initState() {
    super.initState();
    _isKg = widget.initialUnit == WeightUnit.kg;
    _value = _lbsToDisplay(widget.initialValue);
  }

  void _increment() {
    setState(() {
      _value = (_value + _step).clamp(_min, _max);
    });
  }

  void _decrement() {
    setState(() {
      _value = (_value - _step).clamp(_min, _max);
    });
  }

  void _save() {
    final lbsValue = _displayToLbs(_value);
    switch (widget.field) {
      case BiometricField.currentWeight:
        ref.read(biometricProvider.notifier).setCurrentWeight(lbsValue);
      case BiometricField.targetWeight:
        ref.read(biometricProvider.notifier).setTargetWeight(lbsValue);
      case BiometricField.height:
        ref.read(biometricProvider.notifier).setHeight(_value);
    }
    Navigator.pop(context);
  }

  void _toggleUnit() {
    if (!_isWeight) return;
    setState(() {
      final currentLbs = _displayToLbs(_value);
      _isKg = !_isKg;
      _value = _lbsToDisplay(currentLbs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.edit_rounded, color: GritTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Edit $_label',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          if (_isWeight) ...[
            const SizedBox(height: 16),
            _buildUnitToggle(),
          ],
          const SizedBox(height: 24),
          _buildDialButton(Icons.remove_rounded, _decrement),
          const SizedBox(height: 20),
          Container(
            width: 160,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).dividerColor, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  _formatValue(_value),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  _unit,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildDialButton(Icons.add_rounded, _increment),
          const SizedBox(height: 28),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: GritTheme.primary,
              inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              thumbColor: GritTheme.primary,
              overlayColor: GritTheme.primary.withValues(alpha: 0.15),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: _value.clamp(_min, _max),
              min: _min,
              max: _max,
              divisions: ((_max - _min) / _step).round(),
              onChanged: (val) => setState(() => _value = val),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatValue(_min),
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
              Text(
                _formatValue(_max),
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('SAVE'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _unitOption('LBS', !_isKg),
          _unitOption('KG', _isKg),
        ],
      ),
    );
  }

  Widget _unitOption(String label, bool isSelected) {
    return GestureDetector(
      onTap: _toggleUnit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? GritTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? GritTheme.onPrimary : GritTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDialButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: GritTheme.primary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: GritTheme.primary,
          size: 30,
        ),
      ),
    );
  }
}
