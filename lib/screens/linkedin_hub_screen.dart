import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../models/analysis_result.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class LinkedinHubScreen extends StatefulWidget {
  final AnalysisResult result;

  const LinkedinHubScreen({super.key, required this.result});

  @override
  State<LinkedinHubScreen> createState() => _LinkedinHubScreenState();
}

class _LinkedinHubScreenState extends State<LinkedinHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper to generate dynamic headlines based on actual analysis result
  List<Map<String, String>> _generateHeadlines() {
    final persona =
        widget.result.professionalPersona['primary_persona']?.toString() ??
        'Software Engineer';
    final role =
        widget.result.careerGuidance['next_best_move']?.toString() ??
        'Developer';
    final skills = widget.result.matchedSkills
        .take(3)
        .map((s) => s['name']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    final skillsList = skills.isNotEmpty
        ? skills.join(' | ')
        : 'Modern Tech Stack';

    return [
      {
        'title': 'SEO KEYWORD OPTIMIZED',
        'desc': 'Designed to rank high when recruiters search LinkedIn.',
        'content':
            '$role | Specializing in $skillsList | Passions: Building scalable systems & architecture.',
      },
      {
        'title': 'VALUE & IMPACT-FIRST',
        'desc': 'Focuses on the value you bring to engineering teams.',
        'content':
            '$persona. Helping teams solve complex problems and build optimized user experiences using $skillsList.',
      },
      {
        'title': 'STUDENT / ASPIRING PROFESSIONAL',
        'desc': 'Perfect for entry-level landing their first big break.',
        'content':
            'Aspiring $role | Hands-on experience building projects with $skillsList | Passionate learner & problem solver.',
      },
    ];
  }

  // Helper to generate a dynamic about/summary paragraph
  String _generateAboutSummary() {
    final persona =
        widget.result.professionalPersona['primary_persona']?.toString() ??
        'Developer';
    final role =
        widget.result.careerGuidance['next_best_move']?.toString() ??
        'Developer';
    final skills = widget.result.matchedSkills
        .take(3)
        .map((s) => s['name']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    final skillsText = skills.isNotEmpty
        ? 'including ${skills.join(', ')}'
        : 'across multiple modern stacks';
    final bio = widget.result.cultureBio.isNotEmpty
        ? widget.result.cultureBio
        : 'I love building software and collaborating on high-quality codebases.';

    return 'I am a passionate $persona dedicated to building clean, optimized, and impactful digital solutions. My core expertise spans $skillsText, with a strong focus on writing modular, readable, and highly maintainable code.\n\n'
        '$bio\n\n'
        'Currently, I am looking to transition into $role roles where I can contribute to exciting codebases, solve challenging architecture problems, and grow with a world-class team. Let\'s connect!';
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('LinkedIn & Outreach Hub'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'PROFILE BRANDING', icon: Icon(Icons.badge_rounded)),
            Tab(text: 'OUTREACH PLAYBOOK', icon: Icon(Icons.send_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBrandingTab(), _buildOutreachTab()],
      ),
    );
  }

  Widget _buildBrandingTab() {
    final headlines = _generateHeadlines();
    final about = _generateAboutSummary();

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTipCard(
            'LinkedIn is a search engine. Recruiters search by keywords. Having the right Headline and About section can increase your profile views by 10x.',
          ),
          SizedBox(height: 32),
          _buildSectionHeader('OPTIMIZED HEADLINES', Icons.text_fields_rounded),
          SizedBox(height: 16),
          ...headlines.map(
            (h) => _buildHeadlineCard(h['title']!, h['desc']!, h['content']!),
          ),
          SizedBox(height: 32),
          _buildSectionHeader(
            'ABOUT SECTION / BIOGRAPHY',
            Icons.article_rounded,
          ),
          SizedBox(height: 16),
          _buildAboutCard(about),
          SizedBox(height: 40),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildOutreachTab() {
    final scripts = widget.result.outreachTemplates;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTipCard(
            'Never just press "Apply". Finding employees/recruiters at your target company and sending a direct pitch increases interview rates by 40%.',
          ),
          SizedBox(height: 32),
          _buildSectionHeader(
            'OUTREACH PLAYBOOK',
            Icons.send_and_archive_rounded,
          ),
          SizedBox(height: 16),
          if (scripts.isEmpty)
            Text(
              "No outreach scripts found.",
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 13),
            )
          else
            ...scripts.map(
              (s) => _buildScriptCard(
                s['type'] ?? s['title'] ?? 'Template',
                'Custom AI Generated Pitch',
                s['message'] ?? s['content'] ?? '',
              ),
            ),
          SizedBox(height: 40),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildTipCard(String text) {
    return PremiumCard(
      color: AppColors.primary.withValues(alpha: 0.05),
      hasShadow: false,
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
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
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildHeadlineCard(String type, String desc, String content) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                onPressed: () => _copyToClipboard(content, '$type copied!'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          Divider(height: 24, color: AppColors.primary.withValues(alpha: 0.1)),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(String text) {
    return PremiumCard(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STUDENT CAREER SUMMARY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                onPressed: () => _copyToClipboard(text, 'Bio summary copied!'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Divider(height: 24, color: AppColors.primary.withValues(alpha: 0.1)),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.7,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScriptCard(String title, String desc, String content) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
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
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      desc,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () =>
                    _copyToClipboard(content, '$title script copied!'),
              ),
            ],
          ),
          Divider(height: 24, color: AppColors.primary.withValues(alpha: 0.1)),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black26
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              content,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text, String successMsg) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMsg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
