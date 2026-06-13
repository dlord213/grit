import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/avatar_provider.dart';
import '../theme.dart';
import 'avatar_painter.dart';

class AvatarDisplay extends ConsumerWidget {
  final double size;

  const AvatarDisplay({super.key, this.size = 120});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(avatarProvider);
    return Container(
      width: size,
      height: size * 1.4,
      decoration: BoxDecoration(
        color: GritTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GritTheme.darkDivider, width: 2),
        boxShadow: [
          BoxShadow(
            color: GritTheme.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 200,
            height: 280,
            child: CustomPaint(
              painter: AvatarPainter(config: config),
            ),
          ),
        ),
      ),
    );
  }
}

class AvatarHeadDisplay extends ConsumerWidget {
  final double size;

  const AvatarHeadDisplay({super.key, this.size = 44});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(avatarProvider);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: GritTheme.surfaceLight,
        shape: BoxShape.circle,
        border: Border.all(color: GritTheme.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: GritTheme.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: AvatarPainter(config: config, headOnly: true),
            ),
          ),
        ),
      ),
    );
  }
}
