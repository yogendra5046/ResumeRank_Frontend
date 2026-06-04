import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "About ResumeAI",
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildAppHeader(context),
          SizedBox(height: 32),
          Text(
            "OUR FEATURES",
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 16),
          _buildFeatureCard(context,
            "Rank Analysis & ATS Audit",
            Icons.speed_rounded,
            "Analyzes your resume against industry-standard ATS parsers. We audit your layout, formatting, fonts, and structural integrity to ensure your resume never gets blocked by automated tracking systems.",
          ),
          _buildFeatureCard(context,
            "AI Resume Optimizer",
            Icons.auto_fix_high_rounded,
            "Leverages advanced AI to rewrite and enhance your bullet points. We transform weak, passive sentences into strong, impact-driven statements highlighting your measurable achievements.",
          ),
          _buildFeatureCard(context,
            "Keywords & Skill Gaps",
            Icons.radar_rounded,
            "Compares your resume with target job descriptions to identify missing critical skills and keywords, giving you a comprehensive visual gap analysis to guide your upskilling.",
          ),
          _buildFeatureCard(context,
            "Career & Salary Accelerator",
            Icons.trending_up_rounded,
            "Provides a personalized roadmap for your career growth. Discover the skills you need to learn next and the actionable steps required to boost your market value and target higher salary brackets.",
          ),
          _buildFeatureCard(context,
            "LinkedIn & Outreach Playbook",
            Icons.connect_without_contact_rounded,
            "Generates optimized LinkedIn headline and summary suggestions. Furthermore, it provides tailored cold-outreach message templates to connect with recruiters and hiring managers seamlessly.",
          ),
          _buildFeatureCard(context,
            "Interview Prep Master",
            Icons.mic_rounded,
            "Prepares you for the tough questions based on your resume's weaknesses. Generates custom behavioral interview questions and provides frameworks like STAR to structure your best answers.",
          ),
          _buildFeatureCard(context,
            "AI Cover Letter Generator",
            Icons.edit_note_rounded,
            "Instantly creates compelling, tailored cover letters that perfectly align your past experience with the specific job description you are applying for.",
          ),
          SizedBox(height: 32),
          _buildFooter(context),
          SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.document_scanner_rounded,
            size: 64,
            color: AppColors.primary,
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        SizedBox(height: 16),
        Text(
          "ResumeAI",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms),
        SizedBox(height: 8),
        Text(
          "Your ultimate AI career co-pilot.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildFeatureCard(context,String title, IconData icon, String description) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          "Version 1.1.0",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Empowering job seekers with AI-driven intelligence.",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
