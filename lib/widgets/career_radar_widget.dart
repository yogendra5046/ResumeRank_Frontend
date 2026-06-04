import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class CareerRadarWidget extends StatelessWidget {
  final List<Map<String, dynamic>> skills; // [{name: str, value: double}]
  final double size;

  const CareerRadarWidget({super.key, required this.skills, this.size = 250});

  @override
  Widget build(BuildContext context) {
    final labelColor = Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _RadarPainter(skills: skills, labelColor: labelColor)),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<Map<String, dynamic>> skills;
  final Color labelColor;

  _RadarPainter({required this.skills, required this.labelColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) * 0.8;
    final angleStep = (2 * math.pi) / skills.length;

    final linePaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 1. Draw concentric circles
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), linePaint);
    }

    // 2. Draw axes and labels
    for (var i = 0; i < skills.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), linePaint);

      // Label
      final labelRadius = radius + 20;
      final lx = center.dx + labelRadius * math.cos(angle);
      final ly = center.dy + labelRadius * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: skills[i]['name'],
          style: TextStyle(
            color: labelColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(lx - textPainter.width / 2, ly - textPainter.height / 2),
      );
    }

    // 3. Draw data polygon
    final path = Path();
    for (var i = 0; i < skills.length; i++) {
      final value = (skills[i]['value'] as num).toDouble() / 100.0;
      final angle = i * angleStep - math.pi / 2;
      final x = center.dx + radius * value * math.cos(angle);
      final y = center.dy + radius * value * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    // 4. Draw data points
    for (var i = 0; i < skills.length; i++) {
      final value = (skills[i]['value'] as num).toDouble() / 100.0;
      final angle = i * angleStep - math.pi / 2;
      final x = center.dx + radius * value * math.cos(angle);
      final y = center.dy + radius * value * math.sin(angle);

      canvas.drawCircle(Offset(x, y), 4, Paint()..color = AppColors.primary);
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
