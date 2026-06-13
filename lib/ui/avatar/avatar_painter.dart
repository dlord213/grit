import 'package:flutter/material.dart';
import '../../models/avatar_config.dart';

class AvatarPainter extends CustomPainter {
  final AvatarConfig config;
  final bool headOnly;

  AvatarPainter({required this.config, this.headOnly = false});

  static const _border = PaintingStyle.stroke;
  static const _borderWidth = 2.0;
  static const _borderColor = Colors.black87;
  static const _fill = PaintingStyle.fill;

  Paint _fillPaint(Color color) => Paint()
    ..color = color
    ..style = _fill;

  Paint _borderPaint() => Paint()
    ..color = _borderColor
    ..style = _border
    ..strokeWidth = _borderWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = w / 2;

    if (headOnly) {
      _drawHead(canvas, w, h, center);
      _drawHair(canvas, w, h, center);
      _drawExpression(canvas, w, h, center);
      _drawFacialHair(canvas, w, h, center);
      _drawHeadAccessory(canvas, w, h, center);
    } else {
      _drawBody(canvas, w, h, center);
      _drawArms(canvas, w, h, center);
      _drawHead(canvas, w, h, center);
      _drawHair(canvas, w, h, center);
      _drawExpression(canvas, w, h, center);
      _drawFacialHair(canvas, w, h, center);
      _drawHeadAccessory(canvas, w, h, center);
    }
  }

  void _drawBody(Canvas canvas, double w, double h, double center) {
    final bodyTop = h * 0.52;
    final bodyW = w * 0.52;
    final bodyH = h * 0.35;
    final bodyLeft = center - bodyW / 2;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bodyLeft, bodyTop, bodyW, bodyH),
      const Radius.circular(12),
    );

    if (config.outfit == Outfit.shirtless) {
      canvas.drawRRect(bodyRect, _fillPaint(config.skinColor));
    } else {
      canvas.drawRRect(bodyRect, _fillPaint(config.outfitColor));
    }
    canvas.drawRRect(bodyRect, _borderPaint());

    if (config.outfit == Outfit.tankTop || config.outfit == Outfit.tankTop2) {
      _drawTankTopDetails(canvas, bodyLeft, bodyTop, bodyW, bodyH);
    } else if (config.outfit == Outfit.tshirt) {
      _drawTshirtDetails(canvas, bodyLeft, bodyTop, bodyW, bodyH);
    } else if (config.outfit == Outfit.hoodie) {
      _drawHoodieDetails(canvas, bodyLeft, bodyTop, bodyW, bodyH);
    } else if (config.outfit == Outfit.stringer) {
      _drawStringerDetails(canvas, bodyLeft, bodyTop, bodyW, bodyH);
    } else if (config.outfit == Outfit.vest) {
      _drawVestDetails(canvas, bodyLeft, bodyTop, bodyW, bodyH);
    } else if (config.outfit == Outfit.muscleShirt) {
      _drawMuscleShirtDetails(canvas, bodyLeft, bodyTop, bodyW, bodyH);
    } else if (config.outfit == Outfit.tankTop3) {
      _drawTankTop3Details(canvas, bodyLeft, bodyTop, bodyW, bodyH);
    } else if (config.outfit == Outfit.cropTop) {
      _drawCropTopDetails(canvas, bodyLeft, bodyTop, bodyW, bodyH);
    } else if (config.outfit == Outfit.jacket) {
      _drawJacketDetails(canvas, bodyLeft, bodyTop, bodyW, bodyH);
    } else if (config.outfit == Outfit.sweater) {
      _drawSweaterDetails(canvas, bodyLeft, bodyTop, bodyW, bodyH);
    } else if (config.outfit == Outfit.tankTop4) {
      _drawTankTop4Details(canvas, bodyLeft, bodyTop, bodyW, bodyH);
    }
  }

  void _drawTankTopDetails(Canvas canvas, double left, double top, double w, double h) {
    final borderPaint = _borderPaint();
    final path = Path()
      ..moveTo(left + w * 0.35, top)
      ..lineTo(left + w * 0.5, top + h * 0.15)
      ..lineTo(left + w * 0.65, top);
    canvas.drawPath(path, borderPaint);
  }

  void _drawTshirtDetails(Canvas canvas, double left, double top, double w, double h) {
    final borderPaint = _borderPaint();
    canvas.drawLine(
      Offset(left + w * 0.35, top),
      Offset(left + w * 0.65, top),
      borderPaint,
    );
    final sleeveW = w * 0.18;
    final sleeveH = h * 0.25;
    final leftSleeve = RRect.fromRectAndRadius(
      Rect.fromLTWH(left - sleeveW * 0.3, top + 2, sleeveW, sleeveH),
      const Radius.circular(6),
    );
    final rightSleeve = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + w - sleeveW * 0.7, top + 2, sleeveW, sleeveH),
      const Radius.circular(6),
    );
    canvas.drawRRect(leftSleeve, _fillPaint(config.outfitColor));
    canvas.drawRRect(leftSleeve, borderPaint);
    canvas.drawRRect(rightSleeve, _fillPaint(config.outfitColor));
    canvas.drawRRect(rightSleeve, borderPaint);
  }

  void _drawHoodieDetails(Canvas canvas, double left, double top, double w, double h) {
    final borderPaint = _borderPaint();
    final hoodRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + w * 0.1, top - h * 0.08, w * 0.8, h * 0.2),
      const Radius.circular(8),
    );
    canvas.drawRRect(hoodRect, _fillPaint(config.outfitColor));
    canvas.drawRRect(hoodRect, borderPaint);
    final pocketRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + w * 0.2, top + h * 0.55, w * 0.6, h * 0.28),
      const Radius.circular(8),
    );
    canvas.drawRRect(pocketRect, borderPaint);
    canvas.drawLine(
      Offset(left + w * 0.5, top),
      Offset(left + w * 0.5, top + h * 0.85),
      borderPaint,
    );
  }

  void _drawStringerDetails(Canvas canvas, double left, double top, double w, double h) {
    final borderPaint = _borderPaint();
    final narrowW = w * 0.35;
    final narrowLeft = left + (w - narrowW) / 2;
    final narrowBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(narrowLeft, top + h * 0.05, narrowW, h * 0.9),
      const Radius.circular(6),
    );
    canvas.drawRRect(narrowBody, _fillPaint(config.outfitColor));
    canvas.drawRRect(narrowBody, borderPaint);
  }

  void _drawVestDetails(Canvas canvas, double left, double top, double w, double h) {
    final borderPaint = _borderPaint();
    canvas.drawLine(
      Offset(left + w * 0.5, top),
      Offset(left + w * 0.5, top + h * 0.9),
      borderPaint,
    );
    final leftSleeve = RRect.fromRectAndRadius(
      Rect.fromLTWH(left - w * 0.05, top + 2, w * 0.12, h * 0.2),
      const Radius.circular(4),
    );
    final rightSleeve = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + w * 0.93, top + 2, w * 0.12, h * 0.2),
      const Radius.circular(4),
    );
    canvas.drawRRect(leftSleeve, _fillPaint(config.outfitColor));
    canvas.drawRRect(leftSleeve, borderPaint);
    canvas.drawRRect(rightSleeve, _fillPaint(config.outfitColor));
    canvas.drawRRect(rightSleeve, borderPaint);
  }

  void _drawMuscleShirtDetails(Canvas canvas, double left, double top, double w, double h) {
    final borderPaint = _borderPaint();
    final leftSleeve = RRect.fromRectAndRadius(
      Rect.fromLTWH(left - w * 0.08, top - 2, w * 0.16, h * 0.18),
      const Radius.circular(4),
    );
    final rightSleeve = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + w * 0.92, top - 2, w * 0.16, h * 0.18),
      const Radius.circular(4),
    );
    canvas.drawRRect(leftSleeve, _fillPaint(config.outfitColor));
    canvas.drawRRect(leftSleeve, borderPaint);
    canvas.drawRRect(rightSleeve, _fillPaint(config.outfitColor));
    canvas.drawRRect(rightSleeve, borderPaint);
    final neckPath = Path()
      ..moveTo(left + w * 0.3, top)
      ..lineTo(left + w * 0.5, top + h * 0.12)
      ..lineTo(left + w * 0.7, top);
    canvas.drawPath(neckPath, borderPaint);
  }

  void _drawTankTop3Details(Canvas canvas, double left, double top, double w, double h) {
    final borderPaint = _borderPaint();
    final leftStrap = Path()
      ..moveTo(left + w * 0.2, top)
      ..lineTo(left + w * 0.35, top + h * 0.08)
      ..lineTo(left + w * 0.45, top)
      ..close();
    final rightStrap = Path()
      ..moveTo(left + w * 0.55, top)
      ..lineTo(left + w * 0.65, top + h * 0.08)
      ..lineTo(left + w * 0.8, top)
      ..close();
    canvas.drawPath(leftStrap, _fillPaint(config.outfitColor));
    canvas.drawPath(leftStrap, borderPaint);
    canvas.drawPath(rightStrap, _fillPaint(config.outfitColor));
    canvas.drawPath(rightStrap, borderPaint);
  }

  void _drawCropTopDetails(Canvas canvas, double left, double top, double w, double h) {
    final borderPaint = _borderPaint();
    final cropH = h * 0.55;
    final cropRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top + h * 0.1, w, cropH),
      const Radius.circular(10),
    );
    canvas.drawRRect(cropRect, _fillPaint(config.outfitColor));
    canvas.drawRRect(cropRect, borderPaint);
    final bottomHem = RRect.fromRectAndRadius(
      Rect.fromLTWH(left - 2, top + h * 0.1 + cropH - 4, w + 4, 8),
      const Radius.circular(4),
    );
    canvas.drawRRect(bottomHem, borderPaint);
  }

  void _drawJacketDetails(Canvas canvas, double left, double top, double w, double h) {
    final borderPaint = _borderPaint();
    final leftSleeve = RRect.fromRectAndRadius(
      Rect.fromLTWH(left - w * 0.08, top, w * 0.18, h * 0.22),
      const Radius.circular(6),
    );
    final rightSleeve = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + w * 0.9, top, w * 0.18, h * 0.22),
      const Radius.circular(6),
    );
    canvas.drawRRect(leftSleeve, _fillPaint(config.outfitColor));
    canvas.drawRRect(leftSleeve, borderPaint);
    canvas.drawRRect(rightSleeve, _fillPaint(config.outfitColor));
    canvas.drawRRect(rightSleeve, borderPaint);
    canvas.drawLine(
      Offset(left + w * 0.5, top),
      Offset(left + w * 0.5, top + h * 0.9),
      borderPaint,
    );
    final pocketL = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + w * 0.08, top + h * 0.55, w * 0.3, h * 0.25),
      const Radius.circular(6),
    );
    final pocketR = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + w * 0.62, top + h * 0.55, w * 0.3, h * 0.25),
      const Radius.circular(6),
    );
    canvas.drawRRect(pocketL, borderPaint);
    canvas.drawRRect(pocketR, borderPaint);
    final collar = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + w * 0.2, top - h * 0.04, w * 0.6, h * 0.12),
      const Radius.circular(6),
    );
    canvas.drawRRect(collar, _fillPaint(config.outfitColor));
    canvas.drawRRect(collar, borderPaint);
  }

  void _drawSweaterDetails(Canvas canvas, double left, double top, double w, double h) {
    final borderPaint = _borderPaint();
    final neck = RRect.fromRectAndRadius(
      Rect.fromLTWH(left + w * 0.25, top - h * 0.02, w * 0.5, h * 0.1),
      const Radius.circular(6),
    );
    canvas.drawRRect(neck, _fillPaint(config.outfitColor));
    canvas.drawRRect(neck, borderPaint);
    final stripePaint = Paint()
      ..color = config.outfitColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < 3; i++) {
      final y = top + h * 0.35 + i * h * 0.15;
      canvas.drawLine(Offset(left + w * 0.1, y), Offset(left + w * 0.9, y), stripePaint);
    }
  }

  void _drawTankTop4Details(Canvas canvas, double left, double top, double w, double h) {
    final borderPaint = _borderPaint();
    final leftStrap = Path()
      ..moveTo(left + w * 0.15, top)
      ..lineTo(left + w * 0.3, top + h * 0.1)
      ..lineTo(left + w * 0.4, top)
      ..close();
    final rightStrap = Path()
      ..moveTo(left + w * 0.6, top)
      ..lineTo(left + w * 0.7, top + h * 0.1)
      ..lineTo(left + w * 0.85, top)
      ..close();
    canvas.drawPath(leftStrap, _fillPaint(config.outfitColor));
    canvas.drawPath(leftStrap, borderPaint);
    canvas.drawPath(rightStrap, _fillPaint(config.outfitColor));
    canvas.drawPath(rightStrap, borderPaint);
    final logoPaint = Paint()
      ..color = config.outfitColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(
      Rect.fromLTWH(left + w * 0.3, top + h * 0.35, w * 0.4, h * 0.2),
      logoPaint,
    );
  }

  void _drawArms(Canvas canvas, double w, double h, double center) {
    final armW = w * 0.12;
    final armH = h * 0.22;
    final bodyTop = h * 0.54;
    final armY = bodyTop + 4;
    final bodyW = w * 0.52;
    final bodyLeft = center - bodyW / 2;

    final leftArm = RRect.fromRectAndRadius(
      Rect.fromLTWH(bodyLeft - armW - 4, armY, armW, armH),
      const Radius.circular(6),
    );
    final rightArm = RRect.fromRectAndRadius(
      Rect.fromLTWH(bodyLeft + bodyW + 4, armY, armW, armH),
      const Radius.circular(6),
    );

    canvas.drawRRect(leftArm, _fillPaint(config.skinColor));
    canvas.drawRRect(leftArm, _borderPaint());
    canvas.drawRRect(rightArm, _fillPaint(config.skinColor));
    canvas.drawRRect(rightArm, _borderPaint());
  }

  void _drawHead(Canvas canvas, double w, double h, double center) {
    final headSize = headOnly ? w * 0.65 : w * 0.48;
    final headTop = headOnly ? h * 0.1 : h * 0.06;
    final headLeft = center - headSize / 2;

    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(headLeft, headTop, headSize, headSize),
      const Radius.circular(16),
    );

    canvas.drawRRect(headRect, _fillPaint(config.skinColor));
    canvas.drawRRect(headRect, _borderPaint());

    final earW = headSize * 0.12;
    final earH = headSize * 0.2;
    final earY = headTop + headSize * 0.35;
    final leftEar = RRect.fromRectAndRadius(
      Rect.fromLTWH(headLeft - earW - 2, earY, earW, earH),
      const Radius.circular(4),
    );
    final rightEar = RRect.fromRectAndRadius(
      Rect.fromLTWH(headLeft + headSize + 2, earY, earW, earH),
      const Radius.circular(4),
    );
    canvas.drawRRect(leftEar, _fillPaint(config.skinColor));
    canvas.drawRRect(leftEar, _borderPaint());
    canvas.drawRRect(rightEar, _fillPaint(config.skinColor));
    canvas.drawRRect(rightEar, _borderPaint());
  }

  void _drawHair(Canvas canvas, double w, double h, double center) {
    if (config.hairStyle == HairStyle.none) return;

    final headSize = headOnly ? w * 0.65 : w * 0.48;
    final headTop = headOnly ? h * 0.1 : h * 0.06;
    final headLeft = center - headSize / 2;
    final hairPaint = _fillPaint(config.hairColorValue);
    final borderPaint = _borderPaint();

    switch (config.hairStyle) {
      case HairStyle.buzz:
        final buzzRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft + 2, headTop - 4, headSize - 4, headSize * 0.2),
          const Radius.circular(8),
        );
        canvas.drawRRect(buzzRect, hairPaint);
        canvas.drawRRect(buzzRect, borderPaint);

      case HairStyle.short:
        final shortRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 2, headTop - 6, headSize + 4, headSize * 0.28),
          const Radius.circular(10),
        );
        canvas.drawRRect(shortRect, hairPaint);
        canvas.drawRRect(shortRect, borderPaint);

      case HairStyle.spiky:
        final baseY = headTop + 2;
        final spikeW = headSize / 5;
        for (int i = 0; i < 5; i++) {
          final spikeX = headLeft + i * spikeW + spikeW * 0.2;
          final path = Path()
            ..moveTo(spikeX, baseY)
            ..lineTo(spikeX + spikeW * 0.5, baseY - headSize * 0.18 - (i % 2 == 0 ? 6 : 0))
            ..lineTo(spikeX + spikeW * 0.8, baseY)
            ..close();
          canvas.drawPath(path, hairPaint);
          canvas.drawPath(path, borderPaint);
        }

      case HairStyle.mohawk:
        final mohawkRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - headSize * 0.08, headTop - headSize * 0.22, headSize * 0.16, headSize * 0.3),
          const Radius.circular(6),
        );
        canvas.drawRRect(mohawkRect, hairPaint);
        canvas.drawRRect(mohawkRect, borderPaint);

      case HairStyle.ponytail:
        final topHair = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 2, headTop - 4, headSize + 4, headSize * 0.25),
          const Radius.circular(10),
        );
        canvas.drawRRect(topHair, hairPaint);
        canvas.drawRRect(topHair, borderPaint);
        final tailRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft + headSize * 0.7, headTop + 4, headSize * 0.18, headSize * 0.45),
          const Radius.circular(6),
        );
        canvas.drawRRect(tailRect, hairPaint);
        canvas.drawRRect(tailRect, borderPaint);

      case HairStyle.afro:
        final afroRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - headSize * 0.15, headTop - headSize * 0.12, headSize * 1.3, headSize * 0.45),
          Radius.circular(headSize * 0.3),
        );
        canvas.drawRRect(afroRect, hairPaint);
        canvas.drawRRect(afroRect, borderPaint);

      case HairStyle.braids:
        final topHair = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 2, headTop - 4, headSize + 4, headSize * 0.22),
          const Radius.circular(8),
        );
        canvas.drawRRect(topHair, hairPaint);
        canvas.drawRRect(topHair, borderPaint);
        for (int i = 0; i < 3; i++) {
          final braidX = headLeft + headSize * 0.2 + i * headSize * 0.25;
          final braid = RRect.fromRectAndRadius(
            Rect.fromLTWH(braidX, headTop + headSize * 0.15, headSize * 0.08, headSize * 0.4),
            const Radius.circular(4),
          );
          canvas.drawRRect(braid, hairPaint);
          canvas.drawRRect(braid, borderPaint);
        }

      case HairStyle.bun:
        final topHair = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 2, headTop - 4, headSize + 4, headSize * 0.22),
          const Radius.circular(8),
        );
        canvas.drawRRect(topHair, hairPaint);
        canvas.drawRRect(topHair, borderPaint);
        final bun = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - headSize * 0.12, headTop - headSize * 0.18, headSize * 0.24, headSize * 0.2),
          Radius.circular(headSize * 0.12),
        );
        canvas.drawRRect(bun, hairPaint);
        canvas.drawRRect(bun, borderPaint);

      case HairStyle.bowlCut:
        final bowlRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 4, headTop - 6, headSize + 8, headSize * 0.35),
          const Radius.circular(12),
        );
        canvas.drawRRect(bowlRect, hairPaint);
        canvas.drawRRect(bowlRect, borderPaint);
        // Bangs
        final bangs = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft, headTop + headSize * 0.12, headSize, headSize * 0.12),
          const Radius.circular(6),
        );
        canvas.drawRRect(bangs, hairPaint);
        canvas.drawRRect(bangs, borderPaint);

      case HairStyle.curly:
        final baseY = headTop - 2;
        for (int i = 0; i < 7; i++) {
          final curlX = headLeft + headSize * 0.1 + i * headSize * 0.12;
          final curlR = headSize * 0.08 + (i % 2 == 0 ? 2 : 0);
          canvas.drawCircle(Offset(curlX, baseY), curlR, hairPaint);
          canvas.drawCircle(Offset(curlX, baseY), curlR, borderPaint);
        }
        final topCurl = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft, headTop - 4, headSize, headSize * 0.2),
          const Radius.circular(8),
        );
        canvas.drawRRect(topCurl, hairPaint);
        canvas.drawRRect(topCurl, borderPaint);

      case HairStyle.topknot:
        final topHair = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 2, headTop - 4, headSize + 4, headSize * 0.22),
          const Radius.circular(8),
        );
        canvas.drawRRect(topHair, hairPaint);
        canvas.drawRRect(topHair, borderPaint);
        final knot = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - headSize * 0.1, headTop - headSize * 0.22, headSize * 0.2, headSize * 0.18),
          Radius.circular(headSize * 0.1),
        );
        canvas.drawRRect(knot, hairPaint);
        canvas.drawRRect(knot, borderPaint);
        final bandRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - headSize * 0.12, headTop - headSize * 0.06, headSize * 0.24, headSize * 0.06),
          const Radius.circular(3),
        );
        canvas.drawRRect(bandRect, _fillPaint(config.hairColorValue.withValues(alpha: 0.6)));
        canvas.drawRRect(bandRect, borderPaint);

      case HairStyle.dreadlocks:
        final topHair = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 2, headTop - 4, headSize + 4, headSize * 0.25),
          const Radius.circular(8),
        );
        canvas.drawRRect(topHair, hairPaint);
        canvas.drawRRect(topHair, borderPaint);
        for (int i = 0; i < 5; i++) {
          final dreadX = headLeft + headSize * 0.15 + i * headSize * 0.16;
          final dread = RRect.fromRectAndRadius(
            Rect.fromLTWH(dreadX, headTop + headSize * 0.12, headSize * 0.07, headSize * 0.5 + (i % 2 == 0 ? 4 : 0)),
            const Radius.circular(4),
          );
          canvas.drawRRect(dread, hairPaint);
          canvas.drawRRect(dread, borderPaint);
        }

      case HairStyle.fauxHawk:
        final hawkPath = Path()
          ..moveTo(center - headSize * 0.12, headTop + headSize * 0.15)
          ..lineTo(center, headTop - headSize * 0.18)
          ..lineTo(center + headSize * 0.12, headTop + headSize * 0.15)
          ..close();
        canvas.drawPath(hawkPath, hairPaint);
        canvas.drawPath(hawkPath, borderPaint);
        final sideHair = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft, headTop - 2, headSize, headSize * 0.15),
          const Radius.circular(6),
        );
        canvas.drawRRect(sideHair, hairPaint);
        canvas.drawRRect(sideHair, borderPaint);

      case HairStyle.flatTop:
        final flatRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft + 2, headTop - headSize * 0.08, headSize - 4, headSize * 0.18),
          const Radius.circular(2),
        );
        canvas.drawRRect(flatRect, hairPaint);
        canvas.drawRRect(flatRect, borderPaint);
        final sideL = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 2, headTop, headSize * 0.15, headSize * 0.2),
          const Radius.circular(4),
        );
        final sideR = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft + headSize * 0.85, headTop, headSize * 0.15, headSize * 0.2),
          const Radius.circular(4),
        );
        canvas.drawRRect(sideL, hairPaint);
        canvas.drawRRect(sideL, borderPaint);
        canvas.drawRRect(sideR, hairPaint);
        canvas.drawRRect(sideR, borderPaint);

      case HairStyle.pompadour:
        final pompadour = Path()
          ..moveTo(headLeft, headTop + headSize * 0.1)
          ..quadraticBezierTo(center, headTop - headSize * 0.25, headLeft + headSize, headTop + headSize * 0.1)
          ..lineTo(headLeft + headSize, headTop + headSize * 0.18)
          ..quadraticBezierTo(center, headTop - headSize * 0.08, headLeft, headTop + headSize * 0.18)
          ..close();
        canvas.drawPath(pompadour, hairPaint);
        canvas.drawPath(pompadour, borderPaint);

      case HairStyle.cornrows:
        final topHair = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 2, headTop - 4, headSize + 4, headSize * 0.2),
          const Radius.circular(8),
        );
        canvas.drawRRect(topHair, hairPaint);
        canvas.drawRRect(topHair, borderPaint);
        final rowPaint = Paint()
          ..color = hairPaint.color.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        for (int i = 0; i < 4; i++) {
          final y = headTop + headSize * 0.05 + i * headSize * 0.05;
          canvas.drawLine(
            Offset(headLeft + headSize * 0.15, y),
            Offset(headLeft + headSize * 0.85, y),
            rowPaint,
          );
        }
        for (int i = 0; i < 3; i++) {
          final braidX = headLeft + headSize * 0.25 + i * headSize * 0.22;
          final braid = RRect.fromRectAndRadius(
            Rect.fromLTWH(braidX, headTop + headSize * 0.12, headSize * 0.06, headSize * 0.45),
            const Radius.circular(3),
          );
          canvas.drawRRect(braid, hairPaint);
          canvas.drawRRect(braid, borderPaint);
        }

      case HairStyle.mullet:
        final topHair = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 2, headTop - 4, headSize + 4, headSize * 0.22),
          const Radius.circular(8),
        );
        canvas.drawRRect(topHair, hairPaint);
        canvas.drawRRect(topHair, borderPaint);
        final backHair = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft + headSize * 0.15, headTop + headSize * 0.1, headSize * 0.7, headSize * 0.55),
          const Radius.circular(8),
        );
        canvas.drawRRect(backHair, hairPaint);
        canvas.drawRRect(backHair, borderPaint);

      default:
        break;
    }
  }

  void _drawExpression(Canvas canvas, double w, double h, double center) {
    final headSize = headOnly ? w * 0.65 : w * 0.48;
    final headTop = headOnly ? h * 0.1 : h * 0.06;
    final eyeY = headTop + headSize * 0.42;
    final eyeSpacing = headSize * 0.18;
    final eyeW = headSize * 0.1;
    final eyeH = headSize * 0.12;

    final darkPaint = _fillPaint(const Color(0xFF2D2640));
    final borderPaint = _borderPaint();

    switch (config.expression) {
      case Expression.happy:
        final leftEye = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - eyeSpacing - eyeW / 2, eyeY, eyeW, eyeH * 0.6),
          const Radius.circular(4),
        );
        final rightEye = RRect.fromRectAndRadius(
          Rect.fromLTWH(center + eyeSpacing - eyeW / 2, eyeY, eyeW, eyeH * 0.6),
          const Radius.circular(4),
        );
        canvas.drawRRect(leftEye, darkPaint);
        canvas.drawRRect(rightEye, darkPaint);

      case Expression.focused:
        final leftEye = Rect.fromLTWH(center - eyeSpacing - eyeW / 2, eyeY + 2, eyeW, eyeH * 0.5);
        final rightEye = Rect.fromLTWH(center + eyeSpacing - eyeW / 2, eyeY + 2, eyeW, eyeH * 0.5);
        canvas.drawRect(leftEye, darkPaint);
        canvas.drawRect(rightEye, darkPaint);

      case Expression.determined:
        final leftEye = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - eyeSpacing - eyeW / 2, eyeY, eyeW, eyeH),
          const Radius.circular(3),
        );
        final rightEye = RRect.fromRectAndRadius(
          Rect.fromLTWH(center + eyeSpacing - eyeW / 2, eyeY, eyeW, eyeH),
          const Radius.circular(3),
        );
        canvas.drawRRect(leftEye, darkPaint);
        canvas.drawRRect(rightEye, darkPaint);
        final browPaint = Paint()
          ..color = config.hairColorValue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(center - eyeSpacing - eyeW, eyeY - 4),
          Offset(center - eyeSpacing + eyeW * 0.5, eyeY - 1),
          browPaint,
        );
        canvas.drawLine(
          Offset(center + eyeSpacing + eyeW, eyeY - 4),
          Offset(center + eyeSpacing - eyeW * 0.5, eyeY - 1),
          browPaint,
        );

      case Expression.surprised:
        final bigW = eyeW * 1.3;
        final bigH = eyeH * 1.3;
        final leftEye = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - eyeSpacing - bigW / 2, eyeY - 2, bigW, bigH),
          const Radius.circular(6),
        );
        final rightEye = RRect.fromRectAndRadius(
          Rect.fromLTWH(center + eyeSpacing - bigW / 2, eyeY - 2, bigW, bigH),
          const Radius.circular(6),
        );
        canvas.drawRRect(leftEye, darkPaint);
        canvas.drawRRect(rightEye, darkPaint);
        final highlightPaint = _fillPaint(Colors.white);
        canvas.drawCircle(Offset(center - eyeSpacing - 1, eyeY + 2), 2, highlightPaint);
        canvas.drawCircle(Offset(center + eyeSpacing - 1, eyeY + 2), 2, highlightPaint);

      case Expression.wink:
        final leftEye = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - eyeSpacing - eyeW / 2, eyeY, eyeW, eyeH),
          const Radius.circular(3),
        );
        canvas.drawRRect(leftEye, darkPaint);
        final winkPaint = Paint()
          ..color = const Color(0xFF2D2640)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(center + eyeSpacing - eyeW / 2, eyeY + eyeH / 2),
          Offset(center + eyeSpacing + eyeW / 2, eyeY + eyeH / 2),
          winkPaint,
        );

      case Expression.angry:
        final leftEye = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - eyeSpacing - eyeW / 2, eyeY, eyeW, eyeH),
          const Radius.circular(3),
        );
        final rightEye = RRect.fromRectAndRadius(
          Rect.fromLTWH(center + eyeSpacing - eyeW / 2, eyeY, eyeW, eyeH),
          const Radius.circular(3),
        );
        canvas.drawRRect(leftEye, darkPaint);
        canvas.drawRRect(rightEye, darkPaint);
        final browPaint = Paint()
          ..color = const Color(0xFF2D2640)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(center - eyeSpacing - eyeW, eyeY - 6),
          Offset(center - eyeSpacing + eyeW * 0.3, eyeY - 2),
          browPaint,
        );
        canvas.drawLine(
          Offset(center + eyeSpacing + eyeW, eyeY - 6),
          Offset(center + eyeSpacing - eyeW * 0.3, eyeY - 2),
          browPaint,
        );

      case Expression.calm:
        final leftEye = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - eyeSpacing - eyeW / 2, eyeY + 2, eyeW, eyeH * 0.4),
          const Radius.circular(3),
        );
        final rightEye = RRect.fromRectAndRadius(
          Rect.fromLTWH(center + eyeSpacing - eyeW / 2, eyeY + 2, eyeW, eyeH * 0.4),
          const Radius.circular(3),
        );
        canvas.drawRRect(leftEye, darkPaint);
        canvas.drawRRect(rightEye, darkPaint);

      case Expression.smirk:
        final leftEye = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - eyeSpacing - eyeW / 2, eyeY, eyeW, eyeH),
          const Radius.circular(3),
        );
        canvas.drawRRect(leftEye, darkPaint);
        final rightEye = RRect.fromRectAndRadius(
          Rect.fromLTWH(center + eyeSpacing - eyeW / 2, eyeY + 2, eyeW, eyeH * 0.5),
          const Radius.circular(3),
        );
        canvas.drawRRect(rightEye, darkPaint);
    }

    // Mouth
    final mouthY = headTop + headSize * 0.7;
    final mouthW = headSize * 0.2;
    final mouthH = headSize * 0.08;

    switch (config.expression) {
      case Expression.happy:
        final mouth = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - mouthW / 2, mouthY, mouthW, mouthH),
          const Radius.circular(4),
        );
        canvas.drawRRect(mouth, borderPaint);

      case Expression.focused:
        final mouth = Rect.fromLTWH(center - mouthW * 0.35, mouthY + 2, mouthW * 0.7, mouthH * 0.4);
        canvas.drawRect(mouth, borderPaint);

      case Expression.determined:
        final mouthPath = Path()
          ..moveTo(center - mouthW * 0.4, mouthY + mouthH * 0.5)
          ..lineTo(center + mouthW * 0.4, mouthY + mouthH * 0.5);
        canvas.drawPath(mouthPath, borderPaint);

      case Expression.surprised:
        final mouth = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - mouthW * 0.3, mouthY, mouthW * 0.6, mouthH * 1.6),
          const Radius.circular(8),
        );
        canvas.drawRRect(mouth, borderPaint);

      case Expression.wink:
        final mouth = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - mouthW / 2, mouthY, mouthW, mouthH),
          const Radius.circular(4),
        );
        canvas.drawRRect(mouth, borderPaint);

      case Expression.angry:
        final mouthPath = Path()
          ..moveTo(center - mouthW * 0.4, mouthY + mouthH * 0.3)
          ..lineTo(center - mouthW * 0.1, mouthY + mouthH)
          ..lineTo(center + mouthW * 0.1, mouthY + mouthH)
          ..lineTo(center + mouthW * 0.4, mouthY + mouthH * 0.3);
        canvas.drawPath(mouthPath, borderPaint);

      case Expression.calm:
        final mouth = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - mouthW * 0.3, mouthY + 2, mouthW * 0.6, mouthH * 0.5),
          const Radius.circular(4),
        );
        canvas.drawRRect(mouth, borderPaint);

      case Expression.smirk:
        final mouthPath = Path()
          ..moveTo(center - mouthW * 0.3, mouthY + mouthH * 0.5)
          ..lineTo(center + mouthW * 0.4, mouthY + mouthH * 0.2);
        canvas.drawPath(mouthPath, borderPaint);
    }
  }

  void _drawFacialHair(Canvas canvas, double w, double h, double center) {
    if (config.facialHair == FacialHair.none) return;

    final headSize = headOnly ? w * 0.65 : w * 0.48;
    final headTop = headOnly ? h * 0.1 : h * 0.06;
    final beardPaint = _fillPaint(config.hairColorValue);
    final borderPaint = _borderPaint();

    switch (config.facialHair) {
      case FacialHair.none:
        break;
      case FacialHair.stubble:
        final dotPaint = Paint()
          ..color = config.hairColorValue.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        for (int i = 0; i < 12; i++) {
          final dx = center - headSize * 0.15 + (i % 4) * headSize * 0.1;
          final dy = headTop + headSize * 0.65 + (i ~/ 4) * headSize * 0.06;
          canvas.drawCircle(Offset(dx, dy), 1.5, dotPaint);
        }

      case FacialHair.beard:
        final beard = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            center - headSize * 0.22,
            headTop + headSize * 0.6,
            headSize * 0.44,
            headSize * 0.25,
          ),
          const Radius.circular(10),
        );
        canvas.drawRRect(beard, beardPaint);
        canvas.drawRRect(beard, borderPaint);

      case FacialHair.goatee:
        final goatee = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            center - headSize * 0.08,
            headTop + headSize * 0.68,
            headSize * 0.16,
            headSize * 0.15,
          ),
          const Radius.circular(6),
        );
        canvas.drawRRect(goatee, beardPaint);
        canvas.drawRRect(goatee, borderPaint);

      case FacialHair.mustache:
        final mustache = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            center - headSize * 0.18,
            headTop + headSize * 0.58,
            headSize * 0.36,
            headSize * 0.06,
          ),
          const Radius.circular(4),
        );
        canvas.drawRRect(mustache, beardPaint);
        canvas.drawRRect(mustache, borderPaint);
    }
  }

  void _drawHeadAccessory(Canvas canvas, double w, double h, double center) {
    if (config.headAccessory == HeadAccessory.none) return;

    final headSize = headOnly ? w * 0.65 : w * 0.48;
    final headTop = headOnly ? h * 0.1 : h * 0.06;
    final headLeft = center - headSize / 2;
    final borderPaint = _borderPaint();

    switch (config.headAccessory) {
      case HeadAccessory.none:
        break;
      case HeadAccessory.headband:
        final bandH = headSize * 0.08;
        final bandY = headTop + headSize * 0.28;
        final band = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 3, bandY, headSize + 6, bandH),
          const Radius.circular(4),
        );
        canvas.drawRRect(band, _fillPaint(config.headAccessoryColor));
        canvas.drawRRect(band, borderPaint);

      case HeadAccessory.thickBand:
        final bandH = headSize * 0.12;
        final bandY = headTop + headSize * 0.25;
        final band = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 4, bandY, headSize + 8, bandH),
          const Radius.circular(5),
        );
        canvas.drawRRect(band, _fillPaint(config.headAccessoryColor));
        canvas.drawRRect(band, borderPaint);

      case HeadAccessory.sweatband:
        final bandH = headSize * 0.1;
        final bandY = headTop + headSize * 0.22;
        final band = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 5, bandY, headSize + 10, bandH),
          const Radius.circular(5),
        );
        canvas.drawRRect(band, _fillPaint(config.headAccessoryColor));
        canvas.drawRRect(band, borderPaint);
        final drip = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft + headSize * 0.7, bandY + bandH, 4, 8),
          const Radius.circular(2),
        );
        canvas.drawRRect(drip, _fillPaint(config.headAccessoryColor));
        canvas.drawRRect(drip, borderPaint);

      case HeadAccessory.cap:
        final capBrim = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - headSize * 0.1, headTop - headSize * 0.04, headSize * 1.2, headSize * 0.12),
          const Radius.circular(6),
        );
        canvas.drawRRect(capBrim, _fillPaint(config.headAccessoryColor));
        canvas.drawRRect(capBrim, borderPaint);
        final capTop = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft + headSize * 0.05, headTop - headSize * 0.14, headSize * 0.9, headSize * 0.18),
          const Radius.circular(8),
        );
        canvas.drawRRect(capTop, _fillPaint(config.headAccessoryColor));
        canvas.drawRRect(capTop, borderPaint);

      case HeadAccessory.bandana:
        final bandH = headSize * 0.1;
        final bandY = headTop + headSize * 0.2;
        final band = Path()
          ..moveTo(headLeft - 3, bandY + bandH)
          ..lineTo(headLeft + headSize * 0.5, bandY)
          ..lineTo(headLeft + headSize + 3, bandY + bandH * 0.7)
          ..lineTo(headLeft + headSize + 3, bandY + bandH)
          ..lineTo(headLeft - 3, bandY + bandH + bandH * 0.3)
          ..close();
        canvas.drawPath(band, _fillPaint(config.headAccessoryColor));
        canvas.drawPath(band, borderPaint);
        final knot = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft + headSize * 0.85, bandY + bandH, headSize * 0.1, headSize * 0.12),
          const Radius.circular(3),
        );
        canvas.drawRRect(knot, _fillPaint(config.headAccessoryColor));
        canvas.drawRRect(knot, borderPaint);

      case HeadAccessory.beanie:
        final beanieTop = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 4, headTop - headSize * 0.08, headSize + 8, headSize * 0.32),
          Radius.circular(headSize * 0.16),
        );
        canvas.drawRRect(beanieTop, _fillPaint(config.headAccessoryColor));
        canvas.drawRRect(beanieTop, borderPaint);
        final brim = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft - 5, headTop + headSize * 0.18, headSize + 10, headSize * 0.1),
          const Radius.circular(5),
        );
        canvas.drawRRect(brim, _fillPaint(config.headAccessoryColor));
        canvas.drawRRect(brim, borderPaint);
        final pomPom = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - headSize * 0.06, headTop - headSize * 0.14, headSize * 0.12, headSize * 0.1),
          Radius.circular(headSize * 0.06),
        );
        canvas.drawRRect(pomPom, _fillPaint(config.headAccessoryColor));
        canvas.drawRRect(pomPom, borderPaint);

      case HeadAccessory.glasses:
        final glassPaint = _fillPaint(config.headAccessoryColor.withValues(alpha: 0.3));
        final framePaint = _borderPaint()..strokeWidth = 1.5;
        final lensW = headSize * 0.16;
        final lensH = headSize * 0.12;
        final lensY = headTop + headSize * 0.35;
        final glassSpacing = headSize * 0.18;
        final leftLens = RRect.fromRectAndRadius(
          Rect.fromLTWH(center - glassSpacing - lensW / 2 - 2, lensY, lensW, lensH),
          const Radius.circular(4),
        );
        final rightLens = RRect.fromRectAndRadius(
          Rect.fromLTWH(center + glassSpacing - lensW / 2 + 2, lensY, lensW, lensH),
          const Radius.circular(4),
        );
        canvas.drawRRect(leftLens, glassPaint);
        canvas.drawRRect(leftLens, framePaint);
        canvas.drawRRect(rightLens, glassPaint);
        canvas.drawRRect(rightLens, framePaint);
        canvas.drawLine(
          Offset(center - glassSpacing + lensW / 2 - 2, lensY + lensH / 2),
          Offset(center + glassSpacing - lensW / 2 + 2, lensY + lensH / 2),
          framePaint,
        );
        canvas.drawLine(
          Offset(center - glassSpacing - lensW / 2 - 2, lensY + lensH / 2),
          Offset(headLeft - 2, lensY + lensH / 2 - 2),
          framePaint,
        );
        canvas.drawLine(
          Offset(center + glassSpacing + lensW / 2 + 2, lensY + lensH / 2),
          Offset(headLeft + headSize + 2, lensY + lensH / 2 - 2),
          framePaint,
        );

      case HeadAccessory.mask:
        final maskY = headTop + headSize * 0.52;
        final maskH = headSize * 0.28;
        final mask = RRect.fromRectAndRadius(
          Rect.fromLTWH(headLeft + headSize * 0.05, maskY, headSize * 0.9, maskH),
          const Radius.circular(8),
        );
        canvas.drawRRect(mask, _fillPaint(config.headAccessoryColor));
        canvas.drawRRect(mask, borderPaint);
        final strapPaint = Paint()
          ..color = _borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawLine(
          Offset(headLeft + headSize * 0.05, maskY + maskH * 0.3),
          Offset(headLeft - 3, maskY + maskH * 0.2),
          strapPaint,
        );
        canvas.drawLine(
          Offset(headLeft + headSize * 0.95, maskY + maskH * 0.3),
          Offset(headLeft + headSize + 3, maskY + maskH * 0.2),
          strapPaint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant AvatarPainter oldDelegate) {
    return oldDelegate.config != config || oldDelegate.headOnly != headOnly;
  }
}
