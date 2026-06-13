import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/avatar_config.dart';
import '../../providers/avatar_provider.dart';
import '../theme.dart';
import 'avatar_painter.dart';

class AvatarBuilderScreen extends ConsumerStatefulWidget {
  const AvatarBuilderScreen({super.key});

  @override
  ConsumerState<AvatarBuilderScreen> createState() =>
      _AvatarBuilderScreenState();
}

enum _Category { skin, hair, hairColor, expression, facialHair, accessory, outfit }

class _AvatarBuilderScreenState extends ConsumerState<AvatarBuilderScreen> {
  _Category _selectedCategory = _Category.skin;

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(avatarProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_rounded, color: GritTheme.primary),
            SizedBox(width: 8),
            Text('Grit-tar Builder'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPreview(config),
          const SizedBox(height: 8),
          _buildCategoryTabs(),
          const SizedBox(height: 8),
          Expanded(child: _buildComponentPicker(config)),
        ],
      ),
    );
  }

  Widget _buildPreview(AvatarConfig config) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GritTheme.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GritTheme.darkDivider, width: 2),
        boxShadow: [
          BoxShadow(
            color: GritTheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 140,
          height: 196,
          child: CustomPaint(
            painter: AvatarPainter(config: config),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _Category.values.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? GritTheme.primary.withValues(alpha: 0.15)
                      : GritTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? GritTheme.primary : GritTheme.divider,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _categoryLabel(cat),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? GritTheme.primary : GritTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _categoryLabel(_Category cat) => switch (cat) {
    _Category.skin => 'Skin',
    _Category.hair => 'Hair',
    _Category.hairColor => 'Color',
    _Category.expression => 'Face',
    _Category.facialHair => 'Beard',
    _Category.accessory => 'Gear',
    _Category.outfit => 'Outfit',
  };

  Widget _buildComponentPicker(AvatarConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: switch (_selectedCategory) {
        _Category.skin => _buildSkinPicker(config),
        _Category.hair => _buildHairPicker(config),
        _Category.hairColor => _buildHairColorPicker(config),
        _Category.expression => _buildExpressionPicker(config),
        _Category.facialHair => _buildFacialHairPicker(config),
        _Category.accessory => _buildAccessoryPicker(config),
        _Category.outfit => _buildOutfitPicker(config),
      },
    );
  }

  Widget _buildSkinPicker(AvatarConfig config) {
    final tones = SkinTone.values;
    final colors = [
      const Color(0xFFFFDBB4),
      const Color(0xFFE8B88A),
      const Color(0xFFC9956B),
      const Color(0xFF8D6346),
      const Color(0xFF5C3D2E),
    ];
    final labels = ['Light', 'Medium', 'Tan', 'Dark', 'Deep'];
    return _buildOptionGrid(
      items: List.generate(tones.length, (i) => _OptionItem(
        isSelected: config.skinTone == tones[i],
        onTap: () => ref.read(avatarProvider.notifier).setSkinTone(tones[i]),
        child: _buildColorOption(colors[i], labels[i], config.skinTone == tones[i]),
      )),
    );
  }

  Widget _buildHairPicker(AvatarConfig config) {
    final styles = HairStyle.values;
    final labels = ['None', 'Buzz', 'Short', 'Spiky', 'Mohawk', 'Pony', 'Afro', 'Braids', 'Bun', 'Bowl'];
    return _buildOptionGrid(
      items: List.generate(styles.length, (i) => _OptionItem(
        isSelected: config.hairStyle == styles[i],
        onTap: () => ref.read(avatarProvider.notifier).setHairStyle(styles[i]),
        child: _buildMiniAvatar(
          config.copyWith(hairStyle: styles[i]),
          labels[i],
          config.hairStyle == styles[i],
        ),
      )),
    );
  }

  Widget _buildHairColorPicker(AvatarConfig config) {
    final colors = HairColor.values;
    final colorValues = [
      const Color(0xFF2D2640),
      const Color(0xFF6B4226),
      GritTheme.accentWarm,
      GritTheme.primaryLight,
      GritTheme.accent,
      GritTheme.primaryDark,
      const Color(0xFFE8E4E0),
      const Color(0xFFD4652A),
    ];
    final labels = ['Black', 'Brown', 'Blonde', 'Pink', 'Blue', 'Red', 'White', 'Ginger'];
    return _buildOptionGrid(
      items: List.generate(colors.length, (i) => _OptionItem(
        isSelected: config.hairColor == colors[i],
        onTap: () => ref.read(avatarProvider.notifier).setHairColor(colors[i]),
        child: _buildColorOption(colorValues[i], labels[i], config.hairColor == colors[i]),
      )),
    );
  }

  Widget _buildExpressionPicker(AvatarConfig config) {
    final expressions = Expression.values;
    final labels = ['Happy', 'Focus', 'Determined', 'Wow', 'Wink', 'Angry', 'Calm', 'Smirk'];
    return _buildOptionGrid(
      items: List.generate(expressions.length, (i) => _OptionItem(
        isSelected: config.expression == expressions[i],
        onTap: () => ref.read(avatarProvider.notifier).setExpression(expressions[i]),
        child: _buildMiniAvatar(
          config.copyWith(expression: expressions[i]),
          labels[i],
          config.expression == expressions[i],
        ),
      )),
    );
  }

  Widget _buildFacialHairPicker(AvatarConfig config) {
    final hairs = FacialHair.values;
    final labels = ['None', 'Stubble', 'Beard', 'Goatee', 'Stache'];
    return _buildOptionGrid(
      items: List.generate(hairs.length, (i) => _OptionItem(
        isSelected: config.facialHair == hairs[i],
        onTap: () => ref.read(avatarProvider.notifier).setFacialHair(hairs[i]),
        child: _buildMiniAvatar(
          config.copyWith(facialHair: hairs[i]),
          labels[i],
          config.facialHair == hairs[i],
        ),
      )),
    );
  }

  Widget _buildAccessoryPicker(AvatarConfig config) {
    final accessories = HeadAccessory.values;
    final labels = ['None', 'Band', 'Thick', 'Sweat', 'Cap'];
    return _buildOptionGrid(
      items: List.generate(accessories.length, (i) => _OptionItem(
        isSelected: config.headAccessory == accessories[i],
        onTap: () => ref.read(avatarProvider.notifier).setHeadAccessory(accessories[i]),
        child: _buildMiniAvatar(
          config.copyWith(headAccessory: accessories[i]),
          labels[i],
          config.headAccessory == accessories[i],
        ),
      )),
    );
  }

  Widget _buildOutfitPicker(AvatarConfig config) {
    final outfits = Outfit.values;
    final labels = ['Tank', 'Tee', 'Hoodie', 'String', 'Raw', 'Vest', 'Red'];
    return _buildOptionGrid(
      items: List.generate(outfits.length, (i) => _OptionItem(
        isSelected: config.outfit == outfits[i],
        onTap: () => ref.read(avatarProvider.notifier).setOutfit(outfits[i]),
        child: _buildMiniAvatar(
          config.copyWith(outfit: outfits[i]),
          labels[i],
          config.outfit == outfits[i],
        ),
      )),
    );
  }

  Widget _buildColorOption(Color color, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? GritTheme.primary : GritTheme.darkDivider,
              width: isSelected ? 3 : 2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? GritTheme.primary : GritTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMiniAvatar(AvatarConfig cfg, String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 56,
          height: 78,
          child: CustomPaint(
            painter: AvatarPainter(config: cfg),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? GritTheme.primary : GritTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildOptionGrid({required List<_OptionItem> items}) {
    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.78,
      children: items.map((item) {
        return GestureDetector(
          onTap: item.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: item.isSelected
                  ? GritTheme.primary.withValues(alpha: 0.08)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: item.isSelected ? GritTheme.primary : Theme.of(context).dividerColor,
                width: item.isSelected ? 2 : 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: item.child,
          ),
        );
      }).toList(),
    );
  }
}

class _OptionItem {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const _OptionItem({
    required this.isSelected,
    required this.onTap,
    required this.child,
  });
}
