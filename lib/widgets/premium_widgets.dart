import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? accentColor;
  final double? opacity;
  final bool hasShadow;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const PremiumCard({
    super.key,
    required this.child,
    this.height,
    this.width,
    this.padding,
    this.color,
    this.accentColor,
    this.opacity,
    this.hasShadow = true,
    this.borderRadius = 24.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      height: height,
      width: width,
      padding: padding ?? EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface.withValues(alpha: opacity ?? 1.0),
        borderRadius: BorderRadius.circular(borderRadius),
        border: accentColor != null
            ? Border.all(color: accentColor!.withValues(alpha: 0.1), width: 1.5)
            : null,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (margin != null) {
      return Padding(padding: margin!, child: card);
    }
    return card;
  }
}

class PremiumCircularScore extends StatefulWidget {
  final double score;
  final double size;
  final Color color;
  final bool showText;

  const PremiumCircularScore({
    super.key,
    required this.score,
    this.size = 180,
    this.color = AppColors.primary,
    this.showText = true,
  });

  @override
  State<PremiumCircularScore> createState() => _PremiumCircularScoreState();
}

class _PremiumCircularScoreState extends State<PremiumCircularScore>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.score,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _ScorePainter(
                value: _animation.value / 100,
                color: widget.color,
              ),
            ),
            if (widget.showText)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${_animation.value.toInt()}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: widget.size * 0.28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    "/ 100",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                      fontSize: widget.size * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _ScorePainter extends CustomPainter {
  final double value;
  final Color color;

  _ScorePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 16.0;

    // Background track
    final trackPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth, trackPaint);

    // Progress Line
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withValues(alpha: 0.7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth),
      -math.pi / 2,
      2 * math.pi * value,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FeatureIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const FeatureIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

class HoverAnimatedCard extends StatefulWidget {
  final Widget child;

  const HoverAnimatedCard({super.key, required this.child});

  @override
  State<HoverAnimatedCard> createState() => _HoverAnimatedCardState();
}

class _HoverAnimatedCardState extends State<HoverAnimatedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        scale: _isHovered ? 1.05 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class FeatureExplanationBanner extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const FeatureExplanationBanner({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
