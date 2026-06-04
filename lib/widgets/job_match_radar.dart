import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class JobMatchRadar extends StatelessWidget {
  final Map<String, double> scores;

  const JobMatchRadar({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.circle,
          radarBorderData: BorderSide(color: Colors.transparent),
          gridBorderData: BorderSide(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.1),
            width: 1,
          ),
          tickBorderData: BorderSide(color: Colors.transparent),
          ticksTextStyle: TextStyle(color: Colors.transparent),
          tickCount: 4,
          dataSets: [
            // Target Data (Perfect Match)
            RadarDataSet(
              fillColor: AppColors.primary.withValues(alpha: 0.05),
              borderColor: AppColors.primary.withValues(alpha: 0.1),
              entryRadius: 0,
              dataEntries: [
                const RadarEntry(value: 1.0),
                const RadarEntry(value: 1.0),
                const RadarEntry(value: 1.0),
                const RadarEntry(value: 1.0),
                const RadarEntry(value: 1.0),
              ],
            ),
            // User Data
            RadarDataSet(
              fillColor: AppColors.primary.withValues(alpha: 0.25),
              borderColor: AppColors.primary,
              borderWidth: 2,
              entryRadius: 4,
              dataEntries: [
                RadarEntry(value: scores['Technical'] ?? 0.5),
                RadarEntry(value: scores['Leadership'] ?? 0.4),
                RadarEntry(value: scores['Experience'] ?? 0.7),
                RadarEntry(value: scores['Soft Skills'] ?? 0.8),
                RadarEntry(value: scores['Education'] ?? 0.6),
              ],
            ),
          ],
          getTitle: (index, angle) {
            final titles = [
              'Technical',
              'Leadership',
              'Experience',
              'Soft Skills',
              'Education',
            ];
            return RadarChartTitle(text: titles[index], angle: angle);
          },
          titleTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 800),
        swapAnimationCurve: Curves.easeInOutBack,
      ),
    );
  }
}
