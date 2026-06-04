import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lottie/lottie.dart';
import '../models/analysis_result.dart';
import '../models/enhancement_response.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class RewriteScreen extends StatefulWidget {
  final AnalysisResult result;

  const RewriteScreen({super.key, required this.result});

  @override
  State<RewriteScreen> createState() => _RewriteScreenState();
}

class _RewriteScreenState extends State<RewriteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  EnhancementResponse? _enhancement;

  // Simulator State
  late Set<String> _selectedSkillNames;
  late int _baseScore;
  late int _simulatedScore;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedSkillNames = {};
    _baseScore = widget.result.score;
    _simulatedScore = _baseScore;
    _fetchEnhancement();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> _deriveWeakSections() {
    final breakdown = widget.result.scoreBreakdown;
    if (breakdown.isEmpty) return ['Experience', 'Skills'];

    const keyToSection = {
      'keywords': 'Skills & Keywords',
      'experience': 'Experience',
      'verbs': 'Action Verbs',
      'format': 'Format & Structure',
    };

    final weak = <String>[];
    for (final entry in breakdown.entries) {
      final score = (entry.value as num? ?? 100).toInt();
      if (score < 60) {
        final section = keyToSection[entry.key] ?? entry.key;
        weak.add(section);
      }
    }
    return weak.isEmpty ? ['Experience', 'Skills'] : weak;
  }

  Future<void> _fetchEnhancement() async {
    if (widget.result.rawJson != null &&
        widget.result.rawJson!.containsKey('rewritten_text')) {
      if (mounted) {
        setState(() {
          _enhancement = EnhancementResponse.fromJson(widget.result.rawJson!);
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final data = await _apiService.enhanceResume(
        resumeText: widget.result.rawResumeText,
        jdText: widget.result.rawJdText,
        missingSkills: widget.result.missingSkills
            .map((e) => e['name'] as String)
            .toList(),
        weakSections: _deriveWeakSections(),
      );

      if (mounted) {
        setState(() {
          _enhancement = data;
          _isLoading = false;
        });
      }

      if (widget.result.id != null) {
        final updateMap = {
          'rewritten_text': data.rewrittenText,
          'detailed_enhancements': data.detailedEnhancements,
          'skill_route_map': data.skillRouteMap
              .map(
                (r) => {
                  'skill': r.skill,
                  'path': r.path,
                  'project': r.project,
                  'time': r.time,
                  'url': r.url,
                },
              )
              .toList(),
          'tokens_used': data.tokensUsed,
        };
        await HistoryService.updateResultJson(widget.result.id!, updateMap);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _toggleSkill(CriticalSkill skill) {
    setState(() {
      if (_selectedSkillNames.contains(skill.name)) {
        _selectedSkillNames.remove(skill.name);
      } else {
        _selectedSkillNames.add(skill.name);
      }
      final selectedPoints = widget.result.criticalMissing
          .where((s) => _selectedSkillNames.contains(s.name))
          .fold<int>(0, (sum, s) => sum + s.points);
      _simulatedScore = (_baseScore + selectedPoints).clamp(_baseScore, 100);
    });
  }

  String _getGrade(int score) {
    if (score >= 85) return 'A';
    if (score >= 70) return 'B';
    if (score >= 55) return 'C';
    return 'D';
  }

  Color _getScoreColor(int score) {
    if (score < 55) return AppColors.error;
    if (score < 85) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("AI Resume Optimizer"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: "SCORE SIMULATOR", icon: Icon(Icons.speed_rounded)),
            Tab(text: "RANK BOOSTERS", icon: Icon(Icons.bolt_rounded)),
            Tab(text: "SIDE-BY-SIDE DIFF", icon: Icon(Icons.compare_rounded)),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
          ? _buildErrorState()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSimulatorTab(),
                _buildRankBoostersTab(),
                _buildDiffTab(),
              ],
            ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.wifi_off_rounded,
                  size: 56, color: AppColors.error),
            ),
            SizedBox(height: 24),
            Text('AI Enhancement Failed',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface)),
            SizedBox(height: 8),
            Text(
              _error ?? 'An unexpected error occurred.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 13, height: 1.5),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
                _fetchEnhancement();
              },
              icon: Icon(Icons.refresh_rounded),
              label: Text('Retry AI Enhancement'),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Go Back',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B))),
            ),
          ],
        ).animate().fadeIn(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/lottie/ai_scan.json', height: 200),
          SizedBox(height: 24),
          Text(
            "AI is rewriting and optimizing your resume...",
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "This takes about 10-15 seconds. Maximizing ATS keywords...",
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 13),
          ),
        ],
      ).animate().fadeIn(duration: 500.ms),
    );
  }

  // TAB 1: SCORE SIMULATOR
  Widget _buildSimulatorTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FeatureExplanationBanner(
            title: "ATS Score Simulator",
            description: "Test how adding missing critical skills impacts your overall resume score before you even edit your document. Select missing keywords below to watch your grade improve in real-time.",
            icon: Icons.speed_rounded,
          ),
          PremiumCard(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildScoreIndicator(
                      "CURRENT",
                      _baseScore,
                      widget.result.grade,
                    ),
                    Icon(
                      Icons.trending_flat_rounded,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                      size: 28,
                    ),
                    _buildScoreIndicator(
                      "SIMULATED",
                      _simulatedScore,
                      _getGrade(_simulatedScore),
                      isHighlighted: true,
                    ),
                  ],
                ),
                SizedBox(height: 24),
                _buildImpactProgressBar(),
              ],
            ),
          ),
          SizedBox(height: 32),
          _buildHeader(
            "BRIDGING KEYWORD GAPS",
            Icons.add_circle_outline_rounded,
          ),
          SizedBox(height: 16),
          if (widget.result.criticalMissing.isEmpty)
            _buildEmptySimulatorState()
          else
            _buildSkillToggles(),
          SizedBox(height: 32),
          _buildImpactSummary(),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildScoreIndicator(
    String label,
    int score,
    String grade, {
    bool isHighlighted = false,
  }) {
    final color = _getScoreColor(score);
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "$score%",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: isHighlighted ? color : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Text(
            grade,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImpactProgressBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double baseWidth = (widget.result.score / 100) * maxWidth;
        final double simulatedWidth = (_simulatedScore / 100) * maxWidth;
        final int improvement = _simulatedScore - _baseScore;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Simulated Score Impact",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  improvement > 0
                      ? "+$improvement% Gain"
                      : "No updates selected",
                  style: TextStyle(
                    fontSize: 12,
                    color: improvement > 0
                        ? AppColors.success
                        : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                AnimatedContainer(
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                  height: 10,
                  width: simulatedWidth,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                AnimatedContainer(
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                  height: 10,
                  width: baseWidth,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF6366F1)],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkillToggles() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.result.criticalMissing.map((skill) {
        final isSelected = _selectedSkillNames.contains(skill.name);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleSkill(skill),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: 200.ms,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade900,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.add_circle_outline_rounded,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    skill.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "+${skill.points}%",
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : AppColors.success,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImpactSummary() {
    return PremiumCard(
      color: AppColors.primary.withValues(alpha: 0.05),
      hasShadow: false,
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "MATCH INSIGHT",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _selectedSkillNames.isEmpty
                ? "Simulate adding keywords to analyze the score progression. Including critical skills bridges major gaps."
                : "Adding ${_selectedSkillNames.join(', ')} elevates your score grade from ${widget.result.grade} to ${_getGrade(_simulatedScore)}.",
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

  Widget _buildEmptySimulatorState() {
    return Text(
      "All key requirements are already present in your resume!",
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
        fontStyle: FontStyle.italic,
      ),
    );
  }

  // TAB 2: RANK BOOSTERS & SKILL ROADMAPS
  Widget _buildRankBoostersTab() {
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        const FeatureExplanationBanner(
          title: "AI Rank Boosters & Strategy",
          description: "Don't just add keywords randomly. Our AI provides exact, contextual advice on how to integrate missing skills into your bullet points naturally so you pass both the ATS bot and the human recruiter.",
          icon: Icons.bolt_rounded,
        ),
        _buildHeader(
          "ATS Rank Booster recommendations",
          Icons.trending_up_rounded,
        ),
        SizedBox(height: 16),
        ...(_enhancement?.detailedEnhancements ?? []).map(
          (e) => _buildBoosterCard(e),
        ),
        SizedBox(height: 32),
        _buildHeader("Skill Learning Roadmap", Icons.map_outlined),
        SizedBox(height: 16),
        ...(_enhancement?.skillRouteMap ?? []).map(
          (r) => _buildSkillRouteCard(r),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildBoosterCard(String booster) {
    final parts = booster.split(". WHAT TO DO:");
    String header = "";
    String body = booster;
    bool isSplit = false;

    if (parts.length == 2) {
      header = parts[0].replaceAll("WHAT IS MISSING:", "").trim();
      body = parts[1].trim();
      isSplit = true;
    }

    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isSplit ? Colors.redAccent : AppColors.primary)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSplit ? Icons.warning_amber_rounded : Icons.flash_on_rounded,
              color: isSplit ? Colors.redAccent : AppColors.primary,
              size: 16,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSplit) ...[
                  Text(
                    "MISSING: $header",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.redAccent,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                ],
                MarkdownBody(
                  data: body,
                  styleSheet: MarkdownStyleSheet(
                    p: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 13,
                      height: 1.6,
                    ),
                    strong: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillRouteCard(SkillRoute route) {
    return InkWell(
      onTap: () async {
        if (await canLaunchUrlString(route.url)) {
          await launchUrlString(
            route.url,
            mode: LaunchMode.externalApplication,
          );
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: PremiumCard(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    route.skill,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    route.time,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildRouteItem(
              Icons.library_books_outlined,
              "LEARN FROM",
              route.path,
            ),
            Divider(
              height: 24,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            _buildRouteItem(
              Icons.code_rounded,
              "PRACTICAL PROJECT",
              route.project,
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Tap to open resource",
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.open_in_new_rounded,
                  color: AppColors.primary,
                  size: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary.withValues(alpha: 0.4),
              size: 14,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white30,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Padding(
          padding: EdgeInsets.only(left: 22),
          child: Text(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // TAB 3: SIDE-BY-SIDE DIFF
  Widget _buildDiffTab() {
    final rewritten = _enhancement?.rewrittenText ?? "";

    return LayoutBuilder(
      builder: (context, constraints) {
        final useVertical = constraints.maxWidth < 600;

        final originalPanel = _buildTextComparePanel(
          "ORIGINAL RESUME DRAFT",
          widget.result.rawResumeText,
          Colors.redAccent,
          isVerticalLayout: useVertical,
        );
        final rewrittenPanel = _buildTextComparePanel(
          "ENHANCED OPTIMIZED DRAFT",
          rewritten,
          AppColors.success,
          isMarkdown: true,
          isVerticalLayout: useVertical,
        );

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: FeatureExplanationBanner(
                title: "AI Draft Generation",
                description: "We've rewritten your resume to maximize your match rate. The AI aggressively improves your weakest sections, quantifies your achievements, and formats everything beautifully. Look for the green highlights to see exactly what was optimized.",
                icon: Icons.compare_rounded,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: rewritten));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Enhanced text copied!")),
                    );
                  },
                  icon: Icon(Icons.copy_rounded),
                  label: Text("Copy Enhanced Optimizer Text"),
                ),
              ),
            ),
            Expanded(
              child: useVertical
                  ? ListView(
                      padding: EdgeInsets.all(24),
                      children: [
                        originalPanel,
                        SizedBox(height: 24),
                        rewrittenPanel,
                      ],
                    )
                  : Padding(
                      padding: EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: originalPanel),
                          SizedBox(width: 20),
                          Expanded(child: rewrittenPanel),
                        ],
                      ),
                    ),
            ),
          ],
        );
      },
    ).animate().fadeIn();
  }

  Widget _buildTextComparePanel(
    String header,
    String text,
    Color accentColor, {
    bool isMarkdown = false,
    bool isVerticalLayout = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Text(
              header,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                color: accentColor,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ),
          if (isVerticalLayout)
            Padding(
              padding: EdgeInsets.all(16),
              child: isMarkdown
                  ? MarkdownBody(
                      data: text,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.inter(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 13,
                          height: 1.6,
                        ),
                        strong: TextStyle(
                          color: Colors.greenAccent.shade400,
                          backgroundColor: Colors.greenAccent.withValues(alpha: 0.1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : Text(
                      text,
                      style: GoogleFonts.inter(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: isMarkdown
                    ? MarkdownBody(
                        data: text,
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 13,
                            height: 1.6,
                          ),
                          strong: TextStyle(
                            color: Colors.greenAccent.shade400,
                            backgroundColor: Colors.greenAccent.withValues(alpha: 0.1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Text(
                        text,
                        style: GoogleFonts.inter(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
              ),
            ),
        ],
      ),
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
}
