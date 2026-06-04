import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;

  const LogoWidget({super.key, this.size = 40, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: size * 0.5,
                offset: Offset(0, size * 0.2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'RR',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.5,
            ),
          ),
        ),
        if (showText) ...[
          SizedBox(width: 12),
          Text(
            'Resume Rank',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.5,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}
