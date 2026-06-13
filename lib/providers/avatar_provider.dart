import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/avatar_config.dart';

const _kAvatarKey = 'avatar_config';

final avatarProvider = StateNotifierProvider<AvatarNotifier, AvatarConfig>(
  (ref) => AvatarNotifier(),
);

class AvatarNotifier extends StateNotifier<AvatarConfig> {
  AvatarNotifier() : super(const AvatarConfig()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kAvatarKey);
    if (jsonStr != null) {
      try {
        final map = json.decode(jsonStr) as Map<String, dynamic>;
        state = AvatarConfig.fromJson(map);
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAvatarKey, json.encode(state.toJson()));
  }

  void setSkinTone(SkinTone value) {
    state = state.copyWith(skinTone: value);
    _save();
  }

  void setHairStyle(HairStyle value) {
    state = state.copyWith(hairStyle: value);
    _save();
  }

  void setHairColor(HairColor value) {
    state = state.copyWith(hairColor: value);
    _save();
  }

  void setExpression(Expression value) {
    state = state.copyWith(expression: value);
    _save();
  }

  void setHeadAccessory(HeadAccessory value) {
    state = state.copyWith(headAccessory: value);
    _save();
  }

  void setFacialHair(FacialHair value) {
    state = state.copyWith(facialHair: value);
    _save();
  }

  void setOutfit(Outfit value) {
    state = state.copyWith(outfit: value);
    _save();
  }
}
