import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kWeightUnitKey = 'weight_unit';

enum WeightUnit { lbs, kg }

final weightUnitProvider = StateNotifierProvider<WeightUnitNotifier, WeightUnit>(
  (ref) => WeightUnitNotifier(),
);

class WeightUnitNotifier extends StateNotifier<WeightUnit> {
  WeightUnitNotifier() : super(WeightUnit.lbs) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_kWeightUnitKey);
    state = switch (value) {
      'kg' => WeightUnit.kg,
      _ => WeightUnit.lbs,
    };
  }

  Future<void> setUnit(WeightUnit unit) async {
    state = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kWeightUnitKey, unit.name);
  }
}

double lbsToKg(double lbs) => lbs * 0.453592;
double kgToLbs(double kg) => kg / 0.453592;

String formatWeight(double lbs, WeightUnit unit) {
  if (unit == WeightUnit.kg) {
    return '${lbsToKg(lbs).round()} kg';
  }
  return '${lbs.round()} lbs';
}
