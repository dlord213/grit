import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shop_data.dart';
import '../../providers/shop_provider.dart';
import '../theme.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  ShopCategory _selectedCategory = ShopCategory.themes;

  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_rounded, color: GritTheme.accentWarm),
            SizedBox(width: 8),
            Text('GRIT Shop'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: GritTheme.accentWarm.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GritTheme.accentWarm.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: GritTheme.accentWarm, size: 18),
                SizedBox(width: 4),
                Text(
                  '${shopState.gpBalance}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: GritTheme.accentWarm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryTabs(),
          const SizedBox(height: 8),
          Expanded(child: _buildItemList()),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = [
      (ShopCategory.themes, Icons.palette_rounded, 'Themes'),
      (ShopCategory.avatarGear, Icons.person_rounded, 'Avatar'),
      (ShopCategory.plateStyles, Icons.fitness_center_rounded, 'Plates'),
      (ShopCategory.titles, Icons.emoji_events_rounded, 'Titles'),
    ];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat.$1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? GritTheme.primary.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? GritTheme.primary : Theme.of(context).dividerColor,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.$2,
                      size: 16,
                      color: isSelected ? GritTheme.primary : GritTheme.textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      cat.$3,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? GritTheme.primary : GritTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildItemList() {
    final shopState = ref.watch(shopProvider);
    final items = allShopItems.where((item) => item.category == _selectedCategory).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = shopState.ownedItemIds.contains(item.id);
        final isEquipped = _isEquipped(item, shopState);
        final canBuy = shopState.gpBalance >= item.cost && !isOwned;
        final isFree = item.cost == 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildItemTile(
            item: item,
            isOwned: isOwned,
            isEquipped: isEquipped,
            canBuy: canBuy,
            isFree: isFree,
          ),
        );
      },
    );
  }

  bool _isEquipped(ShopItem item, ShopState shopState) {
    switch (item.category) {
      case ShopCategory.themes:
        return shopState.equippedTheme == item.id;
      case ShopCategory.plateStyles:
        return shopState.equippedPlateStyle == item.id;
      case ShopCategory.titles:
        return shopState.equippedTitle == item.id;
      case ShopCategory.avatarGear:
        return false;
    }
  }

  Widget _buildItemTile({
    required ShopItem item,
    required bool isOwned,
    required bool isEquipped,
    required bool canBuy,
    required bool isFree,
  }) {
    final palette = item.category == ShopCategory.themes
        ? themePalettes[themeIdFromItemId(item.id)]
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEquipped
              ? GritTheme.primary
              : Theme.of(context).dividerColor,
          width: isEquipped ? 2 : 1.5,
        ),
        boxShadow: isEquipped
            ? [
                BoxShadow(
                  color: GritTheme.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Preview area
          _buildItemPreview(item, palette),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: const TextStyle(
                      color: GritTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          // Action button
          _buildActionChip(
            item: item,
            isOwned: isOwned,
            isEquipped: isEquipped,
            canBuy: canBuy,
            isFree: isFree,
          ),
        ],
      ),
    );
  }

  Widget _buildItemPreview(ShopItem item, ThemePalette? palette) {
    if (item.category == ShopCategory.themes && palette != null) {
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(child: Container(color: palette.primary)),
            Expanded(child: Container(color: palette.accent)),
            Expanded(child: Container(color: palette.accentWarm)),
            Expanded(child: Container(color: palette.success)),
          ],
        ),
      );
    }

    if (item.category == ShopCategory.plateStyles) {
      final styleName = item.id.replaceFirst('plate_', '');
      final colors = switch (styleName) {
        'neonGlow' => [GritTheme.accent, GritTheme.primary],
        'minimal' => [GritTheme.surfaceMid, GritTheme.divider],
        'retroIron' => [const Color(0xFF4A4A4A), const Color(0xFF6B6B6B)],
        _ => [GritTheme.primary, GritTheme.accent],
      };
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 32,
              decoration: BoxDecoration(
                color: colors[0],
                borderRadius: BorderRadius.circular(2),
                boxShadow: styleName == 'neonGlow'
                    ? [BoxShadow(color: colors[0].withValues(alpha: 0.5), blurRadius: 6)]
                    : null,
              ),
            ),
            const SizedBox(width: 2),
            Container(
              width: 10,
              height: 40,
              decoration: BoxDecoration(
                color: colors[1],
                borderRadius: BorderRadius.circular(2),
                boxShadow: styleName == 'neonGlow'
                    ? [BoxShadow(color: colors[1].withValues(alpha: 0.5), blurRadius: 6)]
                    : null,
              ),
            ),
          ],
        ),
      );
    }

    if (item.category == ShopCategory.titles) {
      final titleId = titleIdFromItemId(item.id);
      final color = titleColor(titleId);
      return Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Icon(
          Icons.emoji_events_rounded,
          color: color,
          size: 24,
        ),
      );
    }

    // Avatar gear
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: GritTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
      ),
      child: Icon(
        _gearIcon(item.id),
        color: GritTheme.primary,
        size: 22,
      ),
    );
  }

  IconData _gearIcon(String itemId) {
    if (itemId.startsWith('hair_')) return Icons.content_cut_rounded;
    if (itemId.startsWith('accessory_')) return Icons.face_rounded;
    if (itemId.startsWith('outfit_')) return Icons.checkroom_rounded;
    if (itemId.startsWith('bg_')) return Icons.wallpaper_rounded;
    return Icons.star_rounded;
  }

  Widget _buildActionChip({
    required ShopItem item,
    required bool isOwned,
    required bool isEquipped,
    required bool canBuy,
    required bool isFree,
  }) {
    if (isEquipped) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: GritTheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
          child: const Text(
            'EQUIPPED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
      );
    }

    if (isOwned && item.category != ShopCategory.avatarGear) {
      return GestureDetector(
        onTap: () => _equipItem(item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: GritTheme.primary, width: 1.5),
          ),
          child: Text(
            'EQUIP',
            style: TextStyle(
              color: GritTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    if (isOwned && item.category == ShopCategory.avatarGear) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: GritTheme.success.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.check_rounded, color: GritTheme.success, size: 18),
      );
    }

    if (isFree) {
      return GestureDetector(
        onTap: () {
          ref.read(shopProvider.notifier).purchaseItem(item);
          if (item.category == ShopCategory.themes) {
            ref.read(shopProvider.notifier).equipTheme(item.id);
          } else if (item.category == ShopCategory.plateStyles) {
            ref.read(shopProvider.notifier).equipPlateStyle(item.id);
          } else if (item.category == ShopCategory.titles) {
            ref.read(shopProvider.notifier).equipTitle(item.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: GritTheme.success.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'FREE',
            style: TextStyle(
              color: GritTheme.success,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: canBuy ? () => _purchaseItem(item) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: canBuy
              ? GritTheme.accentWarm.withValues(alpha: 0.15)
              : Theme.of(context).dividerColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bolt_rounded,
              size: 14,
              color: canBuy ? GritTheme.accentWarm : GritTheme.textSecondary,
            ),
            SizedBox(width: 4),
            Text(
              '${item.cost}',
              style: TextStyle(
                color: canBuy ? GritTheme.accentWarm : GritTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _purchaseItem(ShopItem item) {
    final success = ref.read(shopProvider.notifier).purchaseItem(item);
    if (success) {
      // Auto-equip after purchase
      if (item.category == ShopCategory.themes) {
        ref.read(shopProvider.notifier).equipTheme(item.id);
      } else if (item.category == ShopCategory.plateStyles) {
        ref.read(shopProvider.notifier).equipPlateStyle(item.id);
      } else if (item.category == ShopCategory.titles) {
        ref.read(shopProvider.notifier).equipTitle(item.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unlocked ${item.name}!'),
            backgroundColor: GritTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Not enough GP!'),
            backgroundColor: GritTheme.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      }
    }
  }

  void _equipItem(ShopItem item) {
    if (item.category == ShopCategory.themes) {
      ref.read(shopProvider.notifier).equipTheme(item.id);
    } else if (item.category == ShopCategory.plateStyles) {
      ref.read(shopProvider.notifier).equipPlateStyle(item.id);
    } else if (item.category == ShopCategory.titles) {
      ref.read(shopProvider.notifier).equipTitle(item.id);
    }
  }
}
