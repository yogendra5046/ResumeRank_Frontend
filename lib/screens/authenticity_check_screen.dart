import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/analysis_result.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class AuthenticityCheckScreen extends StatelessWidget {
  final AnalysisResult result;

  const AuthenticityCheckScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text("Authenticity Check")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScoreGauge(context),
                SizedBox(height: 32),
                _buildSectionHeader("RISK ANALYSIS", Icons.fingerprint_rounded),
                SizedBox(height: 16),
                ...result.authenticityCheck.details.map(
                  (detail) => _buildRiskDetail(context, detail),
                ),
                if (result.authenticityCheck.details.isEmpty)
                  _buildAuthenticSlate(context),
                SizedBox(height: 32),
                _buildOptimizationAdvice(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreGauge(BuildContext context) {
    final check = result.authenticityCheck;
    final color = check.score > 80
        ? AppColors.success
        : (check.score > 50 ? AppColors.warning : AppColors.error);

    return PremiumCard(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          PremiumCircularScore(
            score: check.score.toDouble(),
            size: 160,
            color: color,
          ),
          SizedBox(height: 24),
          Text(
            "${check.risk.toUpperCase()} RISK",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Resume Authenticity Score",
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 13),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniMetric(
                context,
                'JD Similarity',
                // Handle both 0.0–1.0 ratio and 0–100 percentage from API
                '${(check.jdSimilarity > 1.0 ? check.jdSimilarity : check.jdSimilarity * 100).clamp(0.0, 100.0).toInt()}%',
              ),
              SizedBox(width: 40),
              _buildMiniMetric(context, 'Plagiarism Risk', check.risk),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskDetail(BuildContext context, String detail) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: AppColors.primary, size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              detail,
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildAuthenticSlate(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.verified_rounded, color: AppColors.success, size: 40),
            SizedBox(height: 16),
            Text(
              "Perfectly Authentic",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "Your resume is unique and avoids the 'copy-paste' trap.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationAdvice(BuildContext context) {
    return PremiumCard(
      color: AppColors.primary.withValues(alpha: 0.05),
      hasShadow: false,
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "OPTIMIZATION ADVICE",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Recruiters and modern ATS systems use similarity checks to find candidates who just 'mirror' the JD. Aim for 60-75% similarity—high enough to be relevant, but low enough to feel authentic and human.",
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
