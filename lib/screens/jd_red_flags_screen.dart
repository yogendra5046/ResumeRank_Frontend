import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/analysis_result.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class JDRedFlagsScreen extends StatelessWidget {
  final AnalysisResult result;

  const JDRedFlagsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text("JD Red Flags")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHealthHeader(context),
                SizedBox(height: 32),
                _buildSectionHeader(
                  "DETECTED ANOMALIES",
                  Icons.warning_amber_rounded,
                ),
                SizedBox(height: 16),
                if (result.jdRedFlags.isEmpty)
                  _buildCleanSlate(context)
                else
                  ...result.jdRedFlags.map((flag) => _buildFlagCard(context, flag)),
                SizedBox(height: 32),
                _buildLegalDisclaimer(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthHeader(BuildContext context) {
    final flagCount = result.jdRedFlags.length;
    final isSafe = flagCount == 0;
    final isWarning = flagCount > 0 && flagCount <= 2;

    Color color = isSafe
        ? AppColors.success
        : (isWarning ? AppColors.warning : AppColors.error);
    String status = isSafe
        ? "SAFE TO APPLY"
        : (isWarning ? "PROCEED WITH CAUTION" : "HIGH RISK DETECTED");
    String desc = isSafe
        ? "No significant red flags detected in this JD. The employer appears transparent."
        : "Our AI detected several patterns that might indicate a challenging work environment.";

    return PremiumCard(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSafe ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
              color: color,
              size: 48,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          SizedBox(height: 20),
          Text(
            status,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
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

  Widget _buildFlagCard(BuildContext context, JDRedFlag flag) {
    Color severityColor = flag.severity == "High"
        ? AppColors.error
        : (flag.severity == "Medium" ? AppColors.warning : AppColors.primary);

    return PremiumCard(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.flag_rounded, color: severityColor, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      flag.flag,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        flag.severity.toUpperCase(),
                        style: TextStyle(
                          color: severityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  flag.description,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildCleanSlate(context) {
    return PremiumCard(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.sentiment_very_satisfied_rounded,
              color: AppColors.success,
              size: 40,
            ),
            SizedBox(height: 16),
            Text(
              "Crystal Clear!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              "This job description is professional and transparent.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalDisclaimer(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Disclaimer: This is an AI-generated health check based on common JD patterns. Always do your own research before applying.",
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
