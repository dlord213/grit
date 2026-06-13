import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

class ForgingCanvas extends StatefulWidget {
  const ForgingCanvas({super.key});

  @override
  State<ForgingCanvas> createState() => _ForgingCanvasState();
}

class _ForgingCanvasState extends State<ForgingCanvas>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          ..._buildStarCluster(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        sin(_bounceController.value * pi * 2) * 8,
                      ),
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 64,
                    color: GritTheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        sin(_bounceController.value * pi * 2 + 0.5) * 6,
                      ),
                      child: child,
                    );
                  },
                  child: Text(
                    'Forging Your Iron Blueprint...',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Building custom workout templates',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStarCluster() {
    final stars = <Widget>[];

    final configs = [
      {'size': 20.0, 'orbit': 80.0, 'speed': 1.0, 'startAngle': 0.0},
      {'size': 14.0, 'orbit': 120.0, 'speed': 0.7, 'startAngle': 1.2},
      {'size': 18.0, 'orbit': 100.0, 'speed': 0.85, 'startAngle': 2.4},
      {'size': 12.0, 'orbit': 140.0, 'speed': 0.6, 'startAngle': 3.6},
      {'size': 16.0, 'orbit': 90.0, 'speed': 0.95, 'startAngle': 4.8},
    ];

    for (int i = 0; i < configs.length; i++) {
      final config = configs[i];
      stars.add(
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            final angle = _rotationController.value * 2 * pi * config['speed']! +
                (config['startAngle'] as double);
            final x = cos(angle) * config['orbit']!;
            final y = sin(angle) * config['orbit']!;

            return Positioned(
              left: MediaQuery.of(context).size.width / 2 + x - config['size']! / 2,
              top: MediaQuery.of(context).size.height / 2 + y - config['size']! / 2 - 40,
              child: Opacity(
                opacity: 0.3 + (sin(angle) + 1) * 0.2,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: config['size']!,
                  color: GritTheme.primary,
                ),
              ),
            );
          },
        ),
      );
    }

    return stars;
  }
}
