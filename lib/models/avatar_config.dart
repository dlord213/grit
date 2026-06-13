import 'package:flutter/material.dart';
import '../ui/theme.dart';

enum SkinTone { light, medium, tan, dark, deep }

enum HairStyle { none, buzz, short, spiky, mohawk, ponytail, afro, braids, bun, bowlCut }

enum HairColor { black, brown, blonde, pink, blue, red, white, ginger }

enum Expression { happy, focused, determined, surprised, wink, angry, calm, smirk }

enum HeadAccessory { none, headband, thickBand, sweatband, cap }

enum FacialHair { none, stubble, beard, goatee, mustache }

enum Outfit { tankTop, tshirt, hoodie, stringer, shirtless, vest, tankTop2 }

class AvatarConfig {
  final SkinTone skinTone;
  final HairStyle hairStyle;
  final HairColor hairColor;
  final Expression expression;
  final HeadAccessory headAccessory;
  final FacialHair facialHair;
  final Outfit outfit;

  const AvatarConfig({
    this.skinTone = SkinTone.light,
    this.hairStyle = HairStyle.buzz,
    this.hairColor = HairColor.brown,
    this.expression = Expression.happy,
    this.headAccessory = HeadAccessory.none,
    this.facialHair = FacialHair.none,
    this.outfit = Outfit.tankTop,
  });

  AvatarConfig copyWith({
    SkinTone? skinTone,
    HairStyle? hairStyle,
    HairColor? hairColor,
    Expression? expression,
    HeadAccessory? headAccessory,
    FacialHair? facialHair,
    Outfit? outfit,
  }) {
    return AvatarConfig(
      skinTone: skinTone ?? this.skinTone,
      hairStyle: hairStyle ?? this.hairStyle,
      hairColor: hairColor ?? this.hairColor,
      expression: expression ?? this.expression,
      headAccessory: headAccessory ?? this.headAccessory,
      facialHair: facialHair ?? this.facialHair,
      outfit: outfit ?? this.outfit,
    );
  }

  Map<String, dynamic> toJson() => {
    'skinTone': skinTone.name,
    'hairStyle': hairStyle.name,
    'hairColor': hairColor.name,
    'expression': expression.name,
    'headAccessory': headAccessory.name,
    'facialHair': facialHair.name,
    'outfit': outfit.name,
  };

  factory AvatarConfig.fromJson(Map<String, dynamic> json) => AvatarConfig(
    skinTone: SkinTone.values.firstWhere(
      (e) => e.name == json['skinTone'],
      orElse: () => SkinTone.light,
    ),
    hairStyle: HairStyle.values.firstWhere(
      (e) => e.name == json['hairStyle'],
      orElse: () => HairStyle.buzz,
    ),
    hairColor: HairColor.values.firstWhere(
      (e) => e.name == json['hairColor'],
      orElse: () => HairColor.brown,
    ),
    expression: Expression.values.firstWhere(
      (e) => e.name == json['expression'],
      orElse: () => Expression.happy,
    ),
    headAccessory: HeadAccessory.values.firstWhere(
      (e) => e.name == json['headAccessory'],
      orElse: () => HeadAccessory.none,
    ),
    facialHair: FacialHair.values.firstWhere(
      (e) => e.name == json['facialHair'],
      orElse: () => FacialHair.none,
    ),
    outfit: Outfit.values.firstWhere(
      (e) => e.name == json['outfit'],
      orElse: () => Outfit.tankTop,
    ),
  );

  Color get skinColor => switch (skinTone) {
    SkinTone.light => const Color(0xFFFFDBB4),
    SkinTone.medium => const Color(0xFFE8B88A),
    SkinTone.tan => const Color(0xFFC9956B),
    SkinTone.dark => const Color(0xFF8D6346),
    SkinTone.deep => const Color(0xFF5C3D2E),
  };

  Color get hairColorValue => switch (hairColor) {
    HairColor.black => const Color(0xFF2D2640),
    HairColor.brown => const Color(0xFF6B4226),
    HairColor.blonde => const Color(0xFFFFD166),
    HairColor.pink => GritTheme.primaryLight,
    HairColor.blue => GritTheme.accent,
    HairColor.red => GritTheme.primaryDark,
    HairColor.white => const Color(0xFFE8E4E0),
    HairColor.ginger => const Color(0xFFD4652A),
  };

  Color get outfitColor => switch (outfit) {
    Outfit.tankTop => GritTheme.primary,
    Outfit.tshirt => GritTheme.accent,
    Outfit.hoodie => GritTheme.accentViolet,
    Outfit.stringer => GritTheme.success,
    Outfit.shirtless => skinColor,
    Outfit.vest => GritTheme.accentWarm,
    Outfit.tankTop2 => const Color(0xFFEF4444),
  };

  Color get headAccessoryColor => switch (headAccessory) {
    HeadAccessory.none => Colors.transparent,
    HeadAccessory.headband => GritTheme.accentWarm,
    HeadAccessory.thickBand => GritTheme.primary,
    HeadAccessory.sweatband => GritTheme.success,
    HeadAccessory.cap => GritTheme.accent,
  };
}
