import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class CareerTipsScreen extends StatelessWidget {
  const CareerTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Insider Vault"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 32),
            _buildSectionTitle(context,
              "ATS CHEAT CODES",
              Icons.terminal_rounded,
              Colors.greenAccent,
            ),
            SizedBox(height: 16),
            _buildTipCard(context,
              "The XYZ Formula",
              "Google's favorite way to show impact: 'Accomplished [X] as measured by [Y], by doing [Z].' Always focus on the result before the action.",
              Icons.functions_rounded,
              Colors.blueAccent,
            ),
            _buildTipCard(context,
              "Exact Keyword Matching",
              "ATS algorithms are often literal. If the Job Description asks for 'Customer Service', do not write 'Client Relations'. Mirror the exact phrasing.",
              Icons.manage_search_rounded,
              Colors.tealAccent,
            ),
            _buildTipCard(context,
              "Contextual Keywords",
              "ATS systems look for keywords near each other to verify expertise. Place 'Python' near 'Data Analysis' to boost your relevance score.",
              Icons.hub_rounded,
              Colors.purpleAccent,
            ),
            _buildTipCard(context,
              "Avoid Complex Formatting",
              "ATS parsers fail on tables, multiple columns, and graphics. Stick to a clean, single-column layout with standard fonts (Arial, Calibri) to guarantee your text is read.",
              Icons.grid_off_rounded,
              Colors.redAccent,
            ),
            SizedBox(height: 32),
            _buildSectionTitle(context,
              "DID YOU KNOW?",
              Icons.lightbulb_outline_rounded,
              Colors.amberAccent,
            ),
            SizedBox(height: 16),
            _buildFactCard(context,
              "The 6-Second Rule",
              "Recruiters spend an average of 6 seconds on the first pass of your resume. The top third of your page (above the fold) must immediately hook them with your best achievements.",
            ),
            _buildFactCard(context,
              "Numbers Win Interviews",
              "Resumes featuring quantifiable metrics (%, \$, time saved) are 40% more likely to land an interview. Never just list duties; list measurable results.",
            ),
            _buildFactCard(context,
              "Hidden Job Market",
              "Up to 80% of jobs are never posted publicly. Networking, direct outreach on LinkedIn, and internal referrals are your most powerful 'Cheat Codes'.",
            ),
            SizedBox(height: 32),
            _buildSectionTitle(context,
              "PRO TIPS",
              Icons.star_border_rounded,
              Colors.cyanAccent,
            ),
            SizedBox(height: 16),
            _buildTipCard(context,
              "Tailor Every Application",
              "A one-size-fits-all resume rarely works. Tweak your 'Summary' and 'Core Skills' sections for every application to directly address the company's specific needs.",
              Icons.tune_rounded,
              Colors.indigoAccent,
            ),
            _buildTipCard(context,
              "Reverse Chronological",
              "Unless you are changing careers completely, always use a reverse-chronological format. It is what recruiters and ATS expect.",
              Icons.history_rounded,
              Colors.orangeAccent,
            ),
            _buildTipCard(context,
              "The 'Show, Don't Tell' Rule",
              "Instead of saying 'Strong leadership skills', write 'Led a team of 15 to deliver a \$2M project ahead of schedule'. Prove your skills with evidence.",
              Icons.visibility_rounded,
              Colors.pinkAccent,
            ),
            _buildTipCard(context,
              "PDF vs Docx",
              "Always export as a PDF unless explicitly told otherwise. Modern ATS can read PDFs perfectly, and it ensures your layout never breaks on the recruiter's computer.",
              Icons.picture_as_pdf_rounded,
              Colors.redAccent,
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Career Hacks",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -1,
          ),
        ).animate().fadeIn().slideX(begin: -0.1),
        SizedBox(height: 8),
        Text(
          "Unfair advantages to help you beat the system and land your dream role.",
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 14),
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildSectionTitle(context,String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(context,String title, String desc, IconData icon, Color color) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildFactCard(context,String title, String desc) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 16),
      color: Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }
}
