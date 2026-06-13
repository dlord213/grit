import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shop_data.dart';
import '../ui/theme.dart';

const _kShopKey = 'shop_state';

class ShopState {
  final int gpBalance;
  final Set<String> ownedItemIds;
  final String equippedTheme;
  final String equippedPlateStyle;
  final String equippedTitle;
  final List<GpTransaction> recentTransactions;

  ShopState({
    this.gpBalance = 0,
    Set<String>? ownedItemIds,
    this.equippedTheme = 'theme_hotPink',
    this.equippedPlateStyle = 'plate_standard',
    this.equippedTitle = 'title_none',
    List<GpTransaction>? recentTransactions,
  })  : ownedItemIds = ownedItemIds ?? {'theme_hotPink', 'plate_standard', 'title_none'},
        recentTransactions = recentTransactions ?? [];

  ShopState copyWith({
    int? gpBalance,
    Set<String>? ownedItemIds,
    String? equippedTheme,
    String? equippedPlateStyle,
    String? equippedTitle,
    List<GpTransaction>? recentTransactions,
  }) {
    return ShopState(
      gpBalance: gpBalance ?? this.gpBalance,
      ownedItemIds: ownedItemIds ?? this.ownedItemIds,
      equippedTheme: equippedTheme ?? this.equippedTheme,
      equippedPlateStyle: equippedPlateStyle ?? this.equippedPlateStyle,
      equippedTitle: equippedTitle ?? this.equippedTitle,
      recentTransactions: recentTransactions ?? this.recentTransactions,
    );
  }

  Map<String, dynamic> toJson() => {
    'gpBalance': gpBalance,
    'ownedItemIds': ownedItemIds.toList(),
    'equippedTheme': equippedTheme,
    'equippedPlateStyle': equippedPlateStyle,
    'equippedTitle': equippedTitle,
    'recentTransactions': recentTransactions.map((t) => t.toJson()).toList(),
  };

  factory ShopState.fromJson(Map<String, dynamic> json) => ShopState(
    gpBalance: json['gpBalance'] as int? ?? 0,
    ownedItemIds: Set<String>.from(json['ownedItemIds'] as List? ?? []),
    equippedTheme: json['equippedTheme'] as String? ?? 'theme_hotPink',
    equippedPlateStyle: json['equippedPlateStyle'] as String? ?? 'plate_standard',
    equippedTitle: json['equippedTitle'] as String? ?? 'title_none',
    recentTransactions: (json['recentTransactions'] as List?)
            ?.map((t) => GpTransaction.fromJson(t as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

class ShopNotifier extends StateNotifier<ShopState> {
  ShopNotifier() : super(ShopState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kShopKey);
    if (jsonStr != null) {
      try {
        final map = json.decode(jsonStr) as Map<String, dynamic>;
        state = ShopState.fromJson(map);
      } catch (_) {}
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kShopKey, json.encode(state.toJson()));
  }

  void addGp(int amount, String reason) {
    final tx = GpTransaction(
      reason: reason,
      amount: amount,
      timestamp: DateTime.now(),
    );
    final updatedTx = [tx, ...state.recentTransactions];
    if (updatedTx.length > 50) updatedTx.removeLast();

    state = state.copyWith(
      gpBalance: state.gpBalance + amount,
      recentTransactions: updatedTx,
    );
    _save();
  }

  bool canPurchase(ShopItem item) {
    return state.gpBalance >= item.cost && !state.ownedItemIds.contains(item.id);
  }

  bool purchaseItem(ShopItem item) {
    if (!canPurchase(item)) return false;

    final tx = GpTransaction(
      reason: 'Purchased ${item.name}',
      amount: -item.cost,
      timestamp: DateTime.now(),
    );
    final updatedTx = [tx, ...state.recentTransactions];
    if (updatedTx.length > 50) updatedTx.removeLast();

    state = state.copyWith(
      gpBalance: state.gpBalance - item.cost,
      ownedItemIds: {...state.ownedItemIds, item.id},
      recentTransactions: updatedTx,
    );
    _save();
    return true;
  }

  void equipTheme(String itemId) {
    state = state.copyWith(equippedTheme: itemId);
    _save();
  }

  void equipPlateStyle(String itemId) {
    state = state.copyWith(equippedPlateStyle: itemId);
    _save();
  }

  void equipTitle(String itemId) {
    state = state.copyWith(equippedTitle: itemId);
    _save();
  }

  bool isOwned(String itemId) => state.ownedItemIds.contains(itemId);

  ShopThemeId get activeThemeId => themeIdFromItemId(state.equippedTheme);
  ShopPlateStyleId get activePlateStyleId => plateStyleIdFromItemId(state.equippedPlateStyle);
  ShopTitleId get activeTitleId => titleIdFromItemId(state.equippedTitle);
}

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier();
});

final activePaletteProvider = Provider<ThemePalette>((ref) {
  final shopState = ref.watch(shopProvider);
  final themeId = themeIdFromItemId(shopState.equippedTheme);
  return themePalettes[themeId]!;
});
