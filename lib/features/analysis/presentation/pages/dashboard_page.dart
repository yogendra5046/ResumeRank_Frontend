import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/analysis_result.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/premium_widgets.dart';
import '../../../../screens/skill_details_screen.dart';
import '../../../../screens/ats_checklist_screen.dart';
import '../../../../screens/rewrite_screen.dart';
import '../../../../screens/career_accelerator_screen.dart';
import '../../../../screens/linkedin_hub_screen.dart';
import '../../../../screens/interview_prep_screen.dart';
import '../../../../screens/ats_xray_screen.dart';
import '../../../../screens/cover_letter_screen.dart';
import '../../../../screens/authenticity_check_screen.dart';
import '../../../../screens/jd_red_flags_screen.dart';
import '../../../../screens/roast_mode_screen.dart';
import '../../data/models/analysis_result_model.dart';

class DashboardPage extends StatelessWidget {
  final AnalysisResult result;

  const DashboardPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text("Rank Analysis")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPremiumScoreHeader(context),
                SizedBox(height: 32),
                _buildMarketInsightRow(context),
                SizedBox(height: 32),
                _buildSectionLabel("DEEP SYSTEMS COGNITION", context),
                SizedBox(height: 16),
                _buildAnalysisGrid(context),
                SizedBox(height: 32),
                _buildQuickTipCard(context),
                SizedBox(height: 40),
                _buildHomeButton(context),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton(
        onPressed: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          "BACK TO DASHBOARD",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumScoreHeader(BuildContext context) {
    return Center(
      child: Column(
        children: [
          PremiumCircularScore(
            score: result.score.toDouble(),
            size: 200,
            color: _getScoreColor(result.score),
          ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
          SizedBox(height: 24),
          Text(
            "${result.grade} RANK",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            result.percentileText ?? "Overall Match Accuracy",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketInsightRow(BuildContext context) {
    final persona =
        result.professionalPersona['primary_persona'] ?? "Specialist";
    final salary = result.estimatedSalary['estimated_range'] ?? "N/A";
    
    // Calculate the top psychological persona from the breakdown map
    final breakdown = result.professionalPersona['persona_breakdown'] as Map? ?? {};
    String topPsychologicalPersona = "General Professional";
    int topScore = -1;
    breakdown.forEach((key, value) {
      if (value is int && value > topScore) {
        topScore = value;
        topPsychologicalPersona = key.toString();
      }
    });
    if (topScore < 2) topPsychologicalPersona = "Balanced Professional";

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FeatureIcon(
                      icon: Icons.psychology_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      persona,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "Detected Career Track",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().slideX(begin: -0.2),
            SizedBox(width: 16),
            Expanded(
              child: PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FeatureIcon(
                      icon: Icons.payments_outlined,
                      color: Color(0xFF10B981),
                    ),
                    SizedBox(height: 16),
                    Text(
                      salary,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "Market Value (LPA)",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().slideX(begin: 0.2),
          ],
        ),
        SizedBox(height: 16),
        // The new Gamified Workplace Persona Card
        InkWell(
          onTap: () => _showPersonaDetails(context, topPsychologicalPersona, breakdown),
          borderRadius: BorderRadius.circular(24),
          child: PremiumCard(
            color: AppColors.primary.withValues(alpha: 0.05),
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 28),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Workplace Persona",
                        style: TextStyle(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "The $topPsychologicalPersona",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
      ],
    );
  }

  void _showPersonaDetails(BuildContext context, String topPersona, Map breakdown) {
    final traits = result.professionalPersona['top_traits'] as List? ?? [];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Your Psychological Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "We analyzed the verbs and adjectives in your resume to determine how hiring managers perceive your work style.",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),
              PremiumCard(
                color: AppColors.primary.withValues(alpha: 0.1),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dominant Trait: $topPersona",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _getAdviceForPersona(topPersona),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (traits.isNotEmpty) ...[
                SizedBox(height: 24),
                Text(
                  "Most Used Impact Words:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: traits.map((t) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      t.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )).toList(),
                ),
              ],
              SizedBox(height: 32),
            ],
          ),
        ));
      },
    );
  }

  String _getAdviceForPersona(String persona) {
    switch (persona) {
      case "Leader/Strategist":
        return "You sound like a natural leader who focuses on big-picture impact. If applying for hands-on technical roles, be sure to add more execution-focused verbs so you don't seem disconnected from the daily grind.";
      case "Technical Specialist":
        return "You frame yourself as a highly capable, hands-on executor. This is great for individual contributor roles. If you want to move into Management, replace words like 'engineered' with 'spearheaded' or 'directed'.";
      case "Architect/Visionary":
        return "You focus on scalable systems and design. Make sure you also include measurable business impact (ROI, cost savings) so stakeholders understand the value of your architecture.";
      case "Collaborator/Support":
        return "You use highly collaborative language. While great for team synergy, ensure you also claim individual victories. Don't let your personal achievements get lost in 'we did X' phrasing.";
      default:
        return "Your resume uses a very balanced tone. You can safely apply to both individual contributor and team-lead roles without sounding mismatched.";
    }
  }

  Widget _buildAnalysisGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _buildMenuCard(
          context,
          "ATS Structure Audit",
          "Format & compliance checks",
          Icons.fact_check_rounded,
          Color(0xFF059669),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => ATSChecklistScreen(
                result: (result as AnalysisResultModel).toOldModel(),
              ),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          "Keywords & Gaps",
          "Hard & soft keyword analysis",
          Icons.bar_chart_rounded,
          Color(0xFF4F46E5),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => SkillDetailsScreen(
                result: (result as AnalysisResultModel).toOldModel(),
              ),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          "Career Accelerator",
          "Roadmaps, templates & insights",
          Icons.speed_rounded,
          Color(0xFFEC4899),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => CareerAcceleratorScreen(
                result: (result as AnalysisResultModel).toOldModel(),
              ),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          "STAR Interview Coach",
          "Behavioral STAR simulation",
          Icons.psychology_rounded,
          Color(0xFF8B5CF6),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const InterviewPrepScreen()),
          ),
        ),
        _buildMenuCard(
          context,
          "AI Resume Optimizer",
          "Dynamic side-by-side diff",
          Icons.auto_awesome_rounded,
          Color(0xFFD97706),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => RewriteScreen(
                result: (result as AnalysisResultModel).toOldModel(),
              ),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          "LinkedIn & Outreach",
          "Biographies & connection pitches",
          Icons.share_rounded,
          Color(0xFF0077B5),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => LinkedinHubScreen(
                result: (result as AnalysisResultModel).toOldModel(),
              ),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          "Cover Letter Generator",
          "Custom tailored drafts",
          Icons.edit_document,
          Color(0xFF10B981),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => CoverLetterScreen(
                result: (result as AnalysisResultModel).toOldModel(),
              ),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          "ATS X-Ray Vision",
          "Raw robot parsing breakdown",
          Icons.troubleshoot_rounded,
          Color(0xFFEAB308),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => ATSXRayScreen(
                result: (result as AnalysisResultModel).toOldModel(),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildExtraFeaturesGrid(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _buildMenuCard(
          context,
          "Authenticity Check",
          "Plagiarism & AI risk score",
          Icons.fingerprint_rounded,
          Color(0xFF10B981),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => AuthenticityCheckScreen(
                result: (result as AnalysisResultModel).toOldModel(),
              ),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          "JD Red Flags",
          "Detect toxic workplace signs",
          Icons.warning_amber_rounded,
          Color(0xFFEF4444),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => JDRedFlagsScreen(
                result: (result as AnalysisResultModel).toOldModel(),
              ),
            ),
          ),
        ),
        _buildMenuCard(
          context,
          "Roast Mode",
          "Brutal resume truth",
          Icons.local_fire_department_rounded,
          Color(0xFFF97316),
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => RoastModeScreen(
                result: (result as AnalysisResultModel).toOldModel(),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return HoverAnimatedCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: PremiumCard(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FeatureIcon(icon: icon, color: color),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTipCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkSurface : const Color(0xFFFFF7ED);
    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF7C2D12);

    return PremiumCard(
      color: backgroundColor,
      accentColor: isDark ? const Color(0xFFEA580C) : null,
      hasShadow: false,
      child: Row(
        children: [
          const FeatureIcon(
            icon: Icons.tips_and_updates_rounded,
            color: Color(0xFFEA580C),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "IMPACT TIP",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFEA580C),
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                if (result.suggestions.isEmpty)
                  Text(
                    "Focus on quantifying your impact with metrics.",
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  ...result.suggestions.take(3).map(
                    (tip) => Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "• ",
                            style: TextStyle(
                              color: Color(0xFFEA580C),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                fontSize: 12,
                                color: textColor,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildCareerRoadmapCard(BuildContext context) {
    final nextRole =
        result.careerGuidance['next_best_move']?.toString() ??
        'Senior Specialist';
    final readiness = (result.careerGuidance['skill_readiness'] as num? ?? 0)
        .toDouble();
    final roadmap =
        (result.careerGuidance['learning_roadmap'] as List?) ??
        (result.careerGuidance['roadmap'] as List?) ??
        [];

    return PremiumCard(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "NEXT BEST MOVE",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      nextRole,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${readiness.toInt()}% Ready",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          LinearProgressIndicator(
            value: readiness / 100,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
          SizedBox(height: 24),
          Text(
            "LEARNING ROADMAP",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: roadmap.isEmpty
                ? Center(
                    child: Text(
                      "Already highly optimized for this role!",
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: roadmap.length,
                    separatorBuilder: (c, i) => SizedBox(width: 12),
                    itemBuilder: (c, i) {
                      final item = roadmap[i];
                      if (item is! Map) return const SizedBox.shrink();
                      final skill =
                          item['skill']?.toString().toUpperCase() ?? 'SKILL';
                      final topics = item['topics'] as List?;
                      final topicText = topics?.isNotEmpty == true
                          ? topics!.first.toString()
                          : item['description']?.toString() ?? '';
                      return Container(
                        width: 160,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              skill,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                topicText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1);
  }

  Widget _buildSectionLabel(String text, BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.5),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score < 45) return AppColors.error;
    if (score < 75) return AppColors.warning;
    return AppColors.success;
  }
}
