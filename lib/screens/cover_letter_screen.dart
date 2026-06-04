import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../models/analysis_result.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class CoverLetterScreen extends StatefulWidget {
  final AnalysisResult result;

  const CoverLetterScreen({super.key, required this.result});

  @override
  State<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends State<CoverLetterScreen> {
  final List<bool> _checklistState = List.filled(5, false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('Cover Letter Master')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FeatureExplanationBanner(
              title: "AI Cover Letter Generator",
              description: "A tailored cover letter increases your chances of getting an interview by 40%. We've analyzed the JD and generated a custom letter that perfectly aligns your background with their requirements.",
              icon: Icons.history_edu_rounded,
            ),
            _buildEducationalSection(),
            SizedBox(height: 32),
            _buildSectionHeader(
              'AI-GENERATED COVER LETTER',
              Icons.auto_awesome_rounded,
            ),
            SizedBox(height: 16),
            _buildCoverLetterCard(),
            SizedBox(height: 32),
            _buildChecklistSection(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationalSection() {
    return PremiumCard(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, color: AppColors.primary),
              SizedBox(width: 12),
              Text(
                'WHAT IS A COVER LETTER?',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'A cover letter is a one-page document that introduces you to a recruiter and explains why you\'re the best fit for a specific job. While a resume shows your history, a cover letter tells your story.',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'HOW TO WRITE ONE:',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 12),
          _buildStep(
            '1. The Hook',
            'Start with a strong opening sentence that mentions the role and your excitement.',
          ),
          _buildStep(
            '2. The \'Why You\'',
            'Connect your specific achievements to the job requirements.',
          ),
          _buildStep(
            '3. The \'Why Them\'',
            'Mention something specific about the company you admire.',
          ),
          _buildStep(
            '4. Call to Action',
            'End by requesting an interview and thanking them.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String title, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
            fontSize: 12,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '$title: ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextSpan(text: desc),
          ],
        ),
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

  Widget _buildCoverLetterCard() {
    final letter = widget.result.coverLetter.trim();

    if (letter.isEmpty) {
      return PremiumCard(
        hasShadow: false,
        color: AppColors.primary.withValues(alpha: 0.03),
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.description_outlined,
                size: 48,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              ),
              SizedBox(height: 16),
              Text(
                'No cover letter generated',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Ensure the backend analysis includes cover letter generation for this JD.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return PremiumCard(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Custom Draft',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              IconButton(
                icon: Icon(Icons.copy_rounded, color: AppColors.primary),
                tooltip: 'Copy cover letter',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: letter));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cover letter copied!')),
                  );
                },
              ),
            ],
          ),
          Divider(height: 32),
          Text(
            letter,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.7,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildChecklistSection() {
    final items = [
      'Is it addressed to a specific person?',
      'Does it mention the exact job title?',
      'Is it under one page (3–4 paragraphs)?',
      'Did you proofread for typos?',
      'Is it saved as a PDF?',
    ];

    final completed = _checklistState.where((c) => c).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(
              'COVER LETTER CHECKLIST',
              Icons.checklist_rounded,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: completed == items.length
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$completed/${items.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: completed == items.length
                      ? AppColors.success
                      : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ...items.asMap().entries.map(
          (entry) => _buildCheckItem(entry.key, entry.value),
        ),
        if (completed == items.length) ...[
          SizedBox(height: 16),
          PremiumCard(
            color: AppColors.success.withValues(alpha: 0.05),
            hasShadow: false,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All checks complete! Your cover letter is ready to send.',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCheckItem(int index, String text) {
    final isChecked = _checklistState[index];
    return GestureDetector(
      onTap: () {
        setState(() => _checklistState[index] = !isChecked);
      },
      child: AnimatedContainer(
        duration: 200.ms,
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isChecked
              ? AppColors.success.withValues(alpha: 0.05)
              : (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E293B)
                  : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked
                ? AppColors.success.withValues(alpha: 0.3)
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.withValues(alpha: 0.15)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isChecked ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isChecked ? AppColors.success : Colors.grey.shade400,
              size: 22,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: isChecked
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
