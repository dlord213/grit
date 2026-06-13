import 'package:flutter/material.dart';
import '../ui/theme.dart';

enum ShopCategory { themes, avatarGear, plateStyles, titles }

enum ShopThemeId { hotPink, cyberMint, retroSalmon, neonViolet, arcticBlue, sunsetGold, forestGreen, midnightPurple }

enum ShopPlateStyleId { standard, neonGlow, minimal, retroIron, gold }

enum ShopTitleId {
  none,
  ironWill,
  prCrusher,
  beastMode,
  gymRat,
  ironMaiden,
  heavyHitter,
  repKing,
  streakLord,
  volumeDemon,
  oneRmLegend,
  warmupKing,
  setDestroyer,
  consistencyKing,
  gritGrinder,
  ironAddict,
  pumpMaster,
}

class ShopItem {
  final String id;
  final String name;
  final int cost;
  final ShopCategory category;
  final String description;
  final Widget? preview;

  const ShopItem({
    required this.id,
    required this.name,
    required this.cost,
    required this.category,
    this.description = '',
    this.preview,
  });
}

class GpTransaction {
  final String reason;
  final int amount;
  final DateTime timestamp;

  const GpTransaction({
    required this.reason,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'reason': reason,
    'amount': amount,
    'timestamp': timestamp.toIso8601String(),
  };

  factory GpTransaction.fromJson(Map<String, dynamic> json) => GpTransaction(
    reason: json['reason'] as String,
    amount: json['amount'] as int,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}

const Map<ShopThemeId, ThemePalette> themePalettes = {
  ShopThemeId.hotPink: ThemePalette(
    primary: Color(0xFFFF6B9D),
    primaryLight: Color(0xFFFFB3CC),
    primaryDark: Color(0xFFE0457A),
    accent: Color(0xFF4ECAFF),
    accentWarm: Color(0xFFFFD166),
    success: Color(0xFF4ECDC4),
    accentViolet: Color(0xFF7B61FF),
  ),
  ShopThemeId.cyberMint: ThemePalette(
    primary: Color(0xFF00C9A7),
    primaryLight: Color(0xFF7EECD8),
    primaryDark: Color(0xFF009E85),
    accent: Color(0xFF6366F1),
    accentWarm: Color(0xFFFBBF24),
    success: Color(0xFF34D399),
    accentViolet: Color(0xFF8B5CF6),
  ),
  ShopThemeId.retroSalmon: ThemePalette(
    primary: Color(0xFFFF6B6B),
    primaryLight: Color(0xFFFFADAD),
    primaryDark: Color(0xFFE04848),
    accent: Color(0xFF4EA8FF),
    accentWarm: Color(0xFFFFD93D),
    success: Color(0xFF6BCB77),
    accentViolet: Color(0xFF9B6BFF),
  ),
  ShopThemeId.neonViolet: ThemePalette(
    primary: Color(0xFFA855F7),
    primaryLight: Color(0xFFD8B4FE),
    primaryDark: Color(0xFF9333EA),
    accent: Color(0xFF06B6D4),
    accentWarm: Color(0xFFFCD34D),
    success: Color(0xFF10B981),
    accentViolet: Color(0xFF7C3AED),
  ),
  ShopThemeId.arcticBlue: ThemePalette(
    primary: Color(0xFF3B82F6),
    primaryLight: Color(0xFF93C5FD),
    primaryDark: Color(0xFF2563EB),
    accent: Color(0xFFF472B6),
    accentWarm: Color(0xFFFBBF24),
    success: Color(0xFF34D399),
    accentViolet: Color(0xFF8B5CF6),
  ),
  ShopThemeId.sunsetGold: ThemePalette(
    primary: Color(0xFFF59E0B),
    primaryLight: Color(0xFFFDE68A),
    primaryDark: Color(0xFFD97706),
    accent: Color(0xFF3B82F6),
    accentWarm: Color(0xFFEF4444),
    success: Color(0xFF10B981),
    accentViolet: Color(0xFF8B5CF6),
  ),
  ShopThemeId.forestGreen: ThemePalette(
    primary: Color(0xFF22C55E),
    primaryLight: Color(0xFF86EFAC),
    primaryDark: Color(0xFF16A34A),
    accent: Color(0xFFF97316),
    accentWarm: Color(0xFFFBBF24),
    success: Color(0xFF14B8A6),
    accentViolet: Color(0xFFA855F7),
  ),
  ShopThemeId.midnightPurple: ThemePalette(
    primary: Color(0xFF6D28D9),
    primaryLight: Color(0xFFC4B5FD),
    primaryDark: Color(0xFF5B21B6),
    accent: Color(0xFFEC4899),
    accentWarm: Color(0xFFFBBF24),
    success: Color(0xFF10B981),
    accentViolet: Color(0xFF7C3AED),
  ),
};

const List<ShopItem> allShopItems = [
  // === Theme Palettes ===
  ShopItem(
    id: 'theme_hotPink',
    name: 'Hot Pink',
    cost: 0,
    category: ShopCategory.themes,
    description: 'The classic Grit palette',
  ),
  ShopItem(
    id: 'theme_cyberMint',
    name: 'Cyber-Mint',
    cost: 500,
    category: ShopCategory.themes,
    description: 'Fresh teal vibes',
  ),
  ShopItem(
    id: 'theme_retroSalmon',
    name: 'Retro Salmon',
    cost: 500,
    category: ShopCategory.themes,
    description: 'Warm coral energy',
  ),
  ShopItem(
    id: 'theme_neonViolet',
    name: 'Neon Violet',
    cost: 500,
    category: ShopCategory.themes,
    description: 'Electric purple glow',
  ),
  ShopItem(
    id: 'theme_arcticBlue',
    name: 'Arctic Blue',
    cost: 500,
    category: ShopCategory.themes,
    description: 'Cool ocean tones',
  ),
  ShopItem(
    id: 'theme_sunsetGold',
    name: 'Sunset Gold',
    cost: 500,
    category: ShopCategory.themes,
    description: 'Golden hour warmth',
  ),
  ShopItem(
    id: 'theme_forestGreen',
    name: 'Forest Green',
    cost: 600,
    category: ShopCategory.themes,
    description: 'Deep forest energy',
  ),
  ShopItem(
    id: 'theme_midnightPurple',
    name: 'Midnight Purple',
    cost: 600,
    category: ShopCategory.themes,
    description: 'Dark royal vibes',
  ),

  // === Avatar Gear - Hair ===
  ShopItem(
    id: 'hair_curly',
    name: 'Curly',
    cost: 300,
    category: ShopCategory.avatarGear,
    description: 'Bouncy curls',
  ),
  ShopItem(
    id: 'hair_topknot',
    name: 'Topknot',
    cost: 300,
    category: ShopCategory.avatarGear,
    description: 'Tied up and ready',
  ),
  ShopItem(
    id: 'hair_dreadlocks',
    name: 'Dreadlocks',
    cost: 400,
    category: ShopCategory.avatarGear,
    description: 'Long flowing locks',
  ),
  ShopItem(
    id: 'hair_fauxHawk',
    name: 'Faux Hawk',
    cost: 350,
    category: ShopCategory.avatarGear,
    description: 'Edgy peak style',
  ),
  ShopItem(
    id: 'hair_flatTop',
    name: 'Flat Top',
    cost: 350,
    category: ShopCategory.avatarGear,
    description: 'Classic military cut',
  ),
  ShopItem(
    id: 'hair_pompadour',
    name: 'Pompadour',
    cost: 400,
    category: ShopCategory.avatarGear,
    description: 'Swept back elegance',
  ),
  ShopItem(
    id: 'hair_cornrows',
    name: 'Cornrows',
    cost: 450,
    category: ShopCategory.avatarGear,
    description: 'Tight braided rows',
  ),
  ShopItem(
    id: 'hair_mullet',
    name: 'Mullet',
    cost: 300,
    category: ShopCategory.avatarGear,
    description: 'Business in front',
  ),

  // === Avatar Gear - Accessories ===
  ShopItem(
    id: 'accessory_bandana',
    name: 'Bandana',
    cost: 250,
    category: ShopCategory.avatarGear,
    description: 'Diagonal head wrap',
  ),
  ShopItem(
    id: 'accessory_beanie',
    name: 'Beanie',
    cost: 250,
    category: ShopCategory.avatarGear,
    description: 'Cozy knit cap',
  ),
  ShopItem(
    id: 'accessory_glasses',
    name: 'Sport Glasses',
    cost: 300,
    category: ShopCategory.avatarGear,
    description: 'Athletic eyewear',
  ),
  ShopItem(
    id: 'accessory_mask',
    name: 'Face Mask',
    cost: 200,
    category: ShopCategory.avatarGear,
    description: 'Gym face covering',
  ),

  // === Avatar Gear - Outfits ===
  ShopItem(
    id: 'outfit_muscleShirt',
    name: 'Muscle Shirt',
    cost: 300,
    category: ShopCategory.avatarGear,
    description: 'Show the gains',
  ),
  ShopItem(
    id: 'outfit_tankTop3',
    name: 'Racer Tank',
    cost: 300,
    category: ShopCategory.avatarGear,
    description: 'Racerback style',
  ),
  ShopItem(
    id: 'outfit_cropTop',
    name: 'Crop Top',
    cost: 350,
    category: ShopCategory.avatarGear,
    description: 'Short and sporty',
  ),
  ShopItem(
    id: 'outfit_jacket',
    name: 'Track Jacket',
    cost: 400,
    category: ShopCategory.avatarGear,
    description: 'Zip-up warmth',
  ),
  ShopItem(
    id: 'outfit_sweater',
    name: 'Sweater',
    cost: 350,
    category: ShopCategory.avatarGear,
    description: 'Cozy crew neck',
  ),
  ShopItem(
    id: 'outfit_tankTop4',
    name: 'Stringer Pro',
    cost: 400,
    category: ShopCategory.avatarGear,
    description: 'Maximum pump',
  ),

  // === Avatar Gear - Backgrounds ===
  ShopItem(
    id: 'bg_gym',
    name: 'Gym BG',
    cost: 200,
    category: ShopCategory.avatarGear,
    description: 'Gym atmosphere',
  ),
  ShopItem(
    id: 'bg_neon',
    name: 'Neon BG',
    cost: 200,
    category: ShopCategory.avatarGear,
    description: 'Neon glow backdrop',
  ),
  ShopItem(
    id: 'bg_sunset',
    name: 'Sunset BG',
    cost: 200,
    category: ShopCategory.avatarGear,
    description: 'Golden hour scene',
  ),

  // === Plate Calculator Styles ===
  ShopItem(
    id: 'plate_standard',
    name: 'Standard',
    cost: 0,
    category: ShopCategory.plateStyles,
    description: 'Classic flat plates',
  ),
  ShopItem(
    id: 'plate_neonGlow',
    name: 'Neon Glow',
    cost: 400,
    category: ShopCategory.plateStyles,
    description: 'Glowing neon plates',
  ),
  ShopItem(
    id: 'plate_minimal',
    name: 'Minimal',
    cost: 400,
    category: ShopCategory.plateStyles,
    description: 'Clean flat design',
  ),
  ShopItem(
    id: 'plate_retroIron',
    name: 'Retro Iron',
    cost: 400,
    category: ShopCategory.plateStyles,
    description: 'Classic iron texture',
  ),
  ShopItem(
    id: 'plate_gold',
    name: 'Gold Plates',
    cost: 600,
    category: ShopCategory.plateStyles,
    description: 'Champion gold finish',
  ),

  // === Titles ===
  ShopItem(
    id: 'title_ironWill',
    name: 'Iron Will',
    cost: 200,
    category: ShopCategory.titles,
    description: 'Unbreakable determination',
  ),
  ShopItem(
    id: 'title_prCrusher',
    name: 'PR Crusher',
    cost: 300,
    category: ShopCategory.titles,
    description: 'Always breaking records',
  ),
  ShopItem(
    id: 'title_beastMode',
    name: 'Beast Mode',
    cost: 500,
    category: ShopCategory.titles,
    description: 'Unleash the beast',
  ),
  ShopItem(
    id: 'title_gymRat',
    name: 'Gym Rat',
    cost: 200,
    category: ShopCategory.titles,
    description: 'Lives at the gym',
  ),
  ShopItem(
    id: 'title_ironMaiden',
    name: 'Iron Maiden',
    cost: 300,
    category: ShopCategory.titles,
    description: 'Queen of iron',
  ),
  ShopItem(
    id: 'title_heavyHitter',
    name: 'Heavy Hitter',
    cost: 400,
    category: ShopCategory.titles,
    description: 'Lifts heavy every day',
  ),
  ShopItem(
    id: 'title_repKing',
    name: 'Rep King',
    cost: 300,
    category: ShopCategory.titles,
    description: 'Master of volume',
  ),
  ShopItem(
    id: 'title_streakLord',
    name: 'Streak Lord',
    cost: 400,
    category: ShopCategory.titles,
    description: 'Never misses a day',
  ),
  ShopItem(
    id: 'title_volumeDemon',
    name: 'Volume Demon',
    cost: 350,
    category: ShopCategory.titles,
    description: 'Infernal work capacity',
  ),
  ShopItem(
    id: 'title_oneRmLegend',
    name: '1RM Legend',
    cost: 600,
    category: ShopCategory.titles,
    description: 'Legendary strength',
  ),
  ShopItem(
    id: 'title_warmupKing',
    name: 'Warmup King',
    cost: 150,
    category: ShopCategory.titles,
    description: 'Never skips warmup',
  ),
  ShopItem(
    id: 'title_setDestroyer',
    name: 'Set Destroyer',
    cost: 350,
    category: ShopCategory.titles,
    description: 'Annihilates every set',
  ),
  ShopItem(
    id: 'title_consistencyKing',
    name: 'Consistency King',
    cost: 400,
    category: ShopCategory.titles,
    description: 'Rain or shine',
  ),
  ShopItem(
    id: 'title_gritGrinder',
    name: 'Grit Grinder',
    cost: 300,
    category: ShopCategory.titles,
    description: 'Built different',
  ),
  ShopItem(
    id: 'title_ironAddict',
    name: 'Iron Addict',
    cost: 450,
    category: ShopCategory.titles,
    description: 'Can\'t stop lifting',
  ),
  ShopItem(
    id: 'title_pumpMaster',
    name: 'Pump Master',
    cost: 250,
    category: ShopCategory.titles,
    description: 'Maximum pump achieved',
  ),
];

ShopThemeId themeIdFromItemId(String itemId) {
  final name = itemId.replaceFirst('theme_', '');
  return ShopThemeId.values.firstWhere(
    (e) => e.name == name,
    orElse: () => ShopThemeId.hotPink,
  );
}

ShopPlateStyleId plateStyleIdFromItemId(String itemId) {
  final name = itemId.replaceFirst('plate_', '');
  return ShopPlateStyleId.values.firstWhere(
    (e) => e.name == name,
    orElse: () => ShopPlateStyleId.standard,
  );
}

ShopTitleId titleIdFromItemId(String itemId) {
  final name = itemId.replaceFirst('title_', '');
  return ShopTitleId.values.firstWhere(
    (e) => e.name == name,
    orElse: () => ShopTitleId.none,
  );
}

String titleDisplayName(ShopTitleId title) => switch (title) {
  ShopTitleId.none => '',
  ShopTitleId.ironWill => 'Iron Will',
  ShopTitleId.prCrusher => 'PR Crusher',
  ShopTitleId.beastMode => 'Beast Mode',
  ShopTitleId.gymRat => 'Gym Rat',
  ShopTitleId.ironMaiden => 'Iron Maiden',
  ShopTitleId.heavyHitter => 'Heavy Hitter',
  ShopTitleId.repKing => 'Rep King',
  ShopTitleId.streakLord => 'Streak Lord',
  ShopTitleId.volumeDemon => 'Volume Demon',
  ShopTitleId.oneRmLegend => '1RM Legend',
  ShopTitleId.warmupKing => 'Warmup King',
  ShopTitleId.setDestroyer => 'Set Destroyer',
  ShopTitleId.consistencyKing => 'Consistency King',
  ShopTitleId.gritGrinder => 'Grit Grinder',
  ShopTitleId.ironAddict => 'Iron Addict',
  ShopTitleId.pumpMaster => 'Pump Master',
};

Color titleColor(ShopTitleId title) => switch (title) {
  ShopTitleId.none => GritTheme.textSecondary,
  ShopTitleId.ironWill => const Color(0xFF94A3B8),
  ShopTitleId.prCrusher => GritTheme.primary,
  ShopTitleId.beastMode => GritTheme.danger,
  ShopTitleId.gymRat => GritTheme.accentWarm,
  ShopTitleId.ironMaiden => GritTheme.accentViolet,
  ShopTitleId.heavyHitter => GritTheme.primaryDark,
  ShopTitleId.repKing => GritTheme.accent,
  ShopTitleId.streakLord => GritTheme.success,
  ShopTitleId.volumeDemon => const Color(0xFFF97316),
  ShopTitleId.oneRmLegend => const Color(0xFFFFD700),
  ShopTitleId.warmupKing => const Color(0xFF06B6D4),
  ShopTitleId.setDestroyer => const Color(0xFFDC2626),
  ShopTitleId.consistencyKing => const Color(0xFF8B5CF6),
  ShopTitleId.gritGrinder => const Color(0xFFD97706),
  ShopTitleId.ironAddict => const Color(0xFF64748B),
  ShopTitleId.pumpMaster => const Color(0xFFEC4899),
};
