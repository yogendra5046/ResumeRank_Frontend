import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/analysis_result.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class ATSChecklistScreen extends StatefulWidget {
  final AnalysisResult result;

  const ATSChecklistScreen({super.key, required this.result});

  @override
  State<ATSChecklistScreen> createState() => _ATSChecklistScreenState();
}

class _ATSChecklistScreenState extends State<ATSChecklistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Core Check Logic
  bool _checkPdfFormat() {
    final score = (widget.result.formatScore['score'] as num? ?? 0).toInt();
    return score > 0;
  }

  bool _checkSectionHeaders() {
    final found =
        (widget.result.atsParse['section_audit']?['found'] as List?) ?? [];
    return found.length >= 3;
  }

  bool _checkContactInfo() {
    final text = widget.result.rawResumeText;
    final hasEmail = RegExp(
      r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}',
    ).hasMatch(text);
    final hasPhone = RegExp(r'(\+?\d[\d\s\-().]{7,}\d)').hasMatch(text);
    return hasEmail && hasPhone;
  }

  bool _checkDateFormats() {
    final dateConsistency = widget.result.atsParse['date_consistency'];
    if (dateConsistency is bool) return dateConsistency;
    if (dateConsistency is String)
      return dateConsistency.toLowerCase() == 'consistent';
    return RegExp(r'\b(19|20)\d{2}\b').hasMatch(widget.result.rawResumeText);
  }

  bool _checkActionVerbs() {
    return (widget.result.verbAnalysis['ratio'] as num? ?? 0) > 50;
  }

  bool _checkKeywordMatch() {
    return widget.result.score > 60;
  }

  bool _checkLayoutSafety() {
    return (widget.result.formatScore['score'] as num? ?? 0) > 70;
  }

  @override
  Widget build(BuildContext context) {
    final checks = [
      _checkPdfFormat(),
      _checkSectionHeaders(),
      _checkContactInfo(),
      _checkDateFormats(),
      _checkActionVerbs(),
      _checkKeywordMatch(),
      _checkLayoutSafety(),
    ];
    final passed = checks.where((c) => c).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('ATS Structural & Format Audit'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: 'COMPLIANCE', icon: Icon(Icons.fact_check_rounded)),
            Tab(
              text: 'SECTIONS & FORMAT',
              icon: Icon(Icons.dashboard_customize_rounded),
            ),
            Tab(text: 'VERB ANALYSIS', icon: Icon(Icons.bolt_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildComplianceTab(passed, checks),
          _buildSectionsTab(),
          _buildVerbsTab(),
        ],
      ),
    );
  }

  Widget _buildComplianceTab(int passed, List<bool> checks) {
    const total = 7;
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        const FeatureExplanationBanner(
          title: "ATS Compliance Check",
          description: "We evaluate your resume against core parsing rules used by top ATS systems (Taleo, Workday). Failing these fundamental checks means your resume might get auto-rejected before a human ever sees it.",
          icon: Icons.fact_check_rounded,
        ),
        _buildSummaryBadge(passed, total),
        SizedBox(height: 24),
        _buildCheckItem(
          'PDF / Parseable Format',
          _checkPdfFormat()
              ? 'Format is successfully read by ATS parsers.'
              : 'Format contains rendering errors or images.',
          _checkPdfFormat(),
        ),
        _buildCheckItem(
          'Section Headers',
          _checkSectionHeaders()
              ? 'All standard section titles detected.'
              : 'Unconventional titles detected.',
          _checkSectionHeaders(),
        ),
        _buildCheckItem(
          'Contact Information',
          _checkContactInfo()
              ? 'Email & phone detected.'
              : 'Missing email or phone number.',
          _checkContactInfo(),
        ),
        _buildCheckItem(
          'Date Formats',
          _checkDateFormats()
              ? 'Consistent timeline patterns found.'
              : 'Inconsistent date layout.',
          _checkDateFormats(),
        ),
        _buildCheckItem(
          'Action Verbs',
          _checkActionVerbs()
              ? 'Strong action verb density.'
              : 'Too many weak / passive statements.',
          _checkActionVerbs(),
        ),
        _buildCheckItem(
          'Keyword Match',
          _checkKeywordMatch()
              ? 'Adequate match score density.'
              : 'Missing too many JD target keywords.',
          _checkKeywordMatch(),
        ),
        _buildCheckItem(
          'Layout Safety',
          _checkLayoutSafety()
              ? 'Clean single-column styling.'
              : 'Complex multi-columns / tables detected.',
          _checkLayoutSafety(),
        ),
        SizedBox(height: 24),
        _buildProTip(passed),
      ],
    ).animate().fadeIn();
  }

  Widget _buildSectionsTab() {
    final warnings = (widget.result.atsParse['format_warnings'] as List? ?? []);
    final audit =
        widget.result.atsParse['section_audit'] as Map<String, dynamic>? ?? {};
    final found = (audit['found'] as List? ?? []);
    final missing = (audit['missing'] as List? ?? []);

    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        const FeatureExplanationBanner(
          title: "Section & Formatting Audit",
          description: "ATS systems rely on standard headers to categorize your data. Creative titles or complex layouts (tables, columns) confuse the parser, causing your experience to be misread or ignored entirely.",
          icon: Icons.dashboard_customize_rounded,
        ),
        _buildSectionStatusCard(warnings),
        SizedBox(height: 32),
        _buildHeader('SECTION INTEGRITY', Icons.segment_rounded),
        SizedBox(height: 16),
        _buildAuditChipsRow(
          'Found Standard Sections',
          found,
          AppColors.success,
        ),
        SizedBox(height: 20),
        _buildAuditChipsRow(
          'Missing standard sections',
          missing,
          Colors.redAccent,
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildVerbsTab() {
    final verbAudit = widget.result.verbAnalysis;
    final weakLines =
        (verbAudit['weak_bullet_points'] as List? ??
        verbAudit['weak_lines'] as List? ??
        []);
    final score = verbAudit['ratio'] ?? verbAudit['score'] ?? 0;

    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        const FeatureExplanationBanner(
          title: "Action Verb Analysis",
          description: "Recruiters and AI screeners look for high-impact candidates. Starting bullet points with strong action verbs (e.g., 'Engineered', 'Orchestrated') scores significantly higher than weak, passive phrases (e.g., 'Responsible for', 'Helped with').",
          icon: Icons.bolt_rounded,
        ),
        PremiumCard(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Action Verb Score",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "$score/100",
                    style: TextStyle(
                      color: score > 70 ? AppColors.success : Colors.redAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                "ATS systems check if you show action and results rather than duties. Strong verbs signify high impact.",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        _buildHeader('WEAK LINES DETECTED', Icons.warning_amber_rounded),
        SizedBox(height: 16),
        if (weakLines.isEmpty)
          PremiumCard(
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Awesome job! Every sentence begins with a strong action verb.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ...weakLines.map(
            (l) => Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: PremiumCard(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildSummaryBadge(int passed, int total) {
    final allPassed = passed == total;
    final color = passed >= total * 0.85
        ? Colors.greenAccent
        : passed >= total * 0.5
        ? Colors.orangeAccent
        : Colors.redAccent;

    return PremiumCard(
      padding: EdgeInsets.all(20),
      accentColor: color,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Text(
              '$passed',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allPassed
                      ? 'ATS Compliant!'
                      : '$passed of $total Checks Passed',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  allPassed
                      ? 'Perfect! No structural errors found.'
                      : '${total - passed} issues need resolving before you apply.',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String title, String subtitle, bool passed) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12),
      accentColor: passed ? Colors.greenAccent : Colors.redAccent,
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: passed ? Colors.greenAccent : Colors.redAccent,
            size: 28,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionStatusCard(List<dynamic> warnings) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: warnings.isEmpty
            ? AppColors.success.withValues(alpha: 0.05)
            : Colors.amber.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: warnings.isEmpty
              ? AppColors.success.withValues(alpha: 0.1)
              : Colors.amber.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            warnings.isEmpty ? "All Systems Go" : "Structure Warnings Detected",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: warnings.isEmpty ? AppColors.success : Colors.amber[900],
            ),
          ),
          SizedBox(height: 8),
          if (warnings.isEmpty)
            Text(
              "Your resume structure follows standard ATS layout rules cleanly.",
              style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
            )
          else
            ...warnings.map(
              (w) => Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        w,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuditChipsRow(String title, List<dynamic> items, Color color) {
    final validItems = items
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 8),
        if (validItems.isEmpty)
          Text(
            'None detected',
            style: TextStyle(color: Colors.white30, fontSize: 12),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: validItems
                .map(
                  (i) => Chip(
                    label: Text(
                      i,
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: color.withValues(alpha: 0.1),
                    side: BorderSide(color: color.withValues(alpha: 0.2)),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildHeader(String title, IconData icon) {
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

  Widget _buildProTip(int passed) {
    const total = 7;
    final remaining = total - passed;
    final tipText = remaining == 0
        ? 'Excellent! Your resume is fully compatible with standard ATS models.'
        : 'Fix the $remaining failing check${remaining > 1 ? 's' : ''} to optimize indexability.';

    return PremiumCard(
      color: AppColors.primary.withValues(alpha: 0.05),
      hasShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_fix_high_rounded,
            color: AppColors.primary,
            size: 28,
          ),
          SizedBox(height: 12),
          Text(
            'Pro Advice',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 6),
          Text(
            tipText,
            style: GoogleFonts.plusJakartaSans(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
