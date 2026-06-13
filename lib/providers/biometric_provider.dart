import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/biometric_config.dart';

const _kBiometricKey = 'biometric_config';

final biometricProvider = StateNotifierProvider<BiometricNotifier, BiometricConfig>(
  (ref) => BiometricNotifier(),
);

class BiometricNotifier extends StateNotifier<BiometricConfig> {
  BiometricNotifier() : super(const BiometricConfig()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kBiometricKey);
    if (jsonStr != null) {
      try {
        final map = json.decode(jsonStr) as Map<String, dynamic>;
        state = BiometricConfig.fromJson(map);
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBiometricKey, json.encode(state.toJson()));
  }

  void setFullName(String value) {
    state = state.copyWith(fullName: value);
    _save();
  }

  void setAge(int value) {
    state = state.copyWith(age: value);
    _save();
  }

  void setCurrentWeight(double value) {
    state = state.copyWith(currentWeight: value);
    _save();
  }

  void setTargetWeight(double value) {
    state = state.copyWith(targetWeight: value);
    _save();
  }

  void setHeight(double value) {
    state = state.copyWith(height: value);
    _save();
  }
}
