import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/analysis_result.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/career_radar_widget.dart';
import 'package:glass_kit/glass_kit.dart';

class SkillDetailsScreen extends StatefulWidget {
  final AnalysisResult result;

  const SkillDetailsScreen({super.key, required this.result});

  @override
  State<SkillDetailsScreen> createState() => _SkillDetailsScreenState();
}

class _SkillDetailsScreenState extends State<SkillDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showRadar = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Keywords & Skill Gaps'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'GAP ANALYSIS', icon: Icon(Icons.bar_chart_rounded)),
            Tab(text: 'KEYWORDS PLAYBOOK', icon: Icon(Icons.key_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildGapTab(), _buildKeywordsTab()],
      ),
    );
  }

  Widget _buildGapTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FeatureExplanationBanner(
            title: "Skill Gap Analysis",
            description: "We map your current skills against the specific requirements of the job description. This radar chart reveals exactly which categories of expertise you are missing so you can target your learning.",
            icon: Icons.bar_chart_rounded,
          ),
          _buildChartHeader(),
          SizedBox(height: 32),
          Text(
            "Detailed Breakdown",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Focus on improving 'Critical Gap' areas first.",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 20),
          if (widget.result.skillGapChart.isEmpty)
            const _EmptyState()
          else
            ...widget.result.skillGapChart.map((gap) => _buildGapTile(gap)),
          SizedBox(height: 40),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildKeywordsTab() {
    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        const FeatureExplanationBanner(
          title: "Keywords Playbook",
          description: "ATS systems parse resumes by searching for exact keyword matches. This playbook categorizes critical missing terms you must add to pass the automated screening filter.",
          icon: Icons.key_rounded,
        ),
        _buildSectionHeader(
          "CRITICAL MISSING SKILLS",
          Icons.warning_amber_rounded,
          Colors.redAccent,
        ),
        SizedBox(height: 16),
        if (widget.result.criticalMissing.isEmpty)
          _buildEmptyKeywordsState()
        else
          ...widget.result.criticalMissing.map(
            (skill) => _buildCriticalTile(skill),
          ),
        SizedBox(height: 32),
        _buildSectionHeader(
          "MATCHED KEYWORDS",
          Icons.check_circle_outline_rounded,
          Colors.greenAccent,
        ),
        SizedBox(height: 16),
        if (widget.result.matchedSkills.isEmpty)
          Text(
            "No matches detected.",
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 12),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.result.matchedSkills
                .map(
                  (s) => _buildKeywordChip(
                    s['name'] as String,
                    Colors.greenAccent,
                  ),
                )
                .toList(),
          ),
        SizedBox(height: 32),
        _buildSectionHeader(
          "MISSING KEYWORDS",
          Icons.error_outline_rounded,
          Colors.orangeAccent,
        ),
        SizedBox(height: 16),
        if (widget.result.missingKeywords.isEmpty)
          Text(
            "No keywords missing!",
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 12),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.result.missingKeywords
                .map((kw) => _buildKeywordChip(kw, Colors.orangeAccent))
                .toList(),
          ),
        SizedBox(height: 40),
      ],
    ).animate().fadeIn();
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
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

  Widget _buildKeywordChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withValues(alpha: 0.8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCriticalTile(CriticalSkill skill) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.bolt_rounded, color: Colors.redAccent),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Required by ${skill.jobs} of matching roles",
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

  Widget _buildEmptyKeywordsState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        "All critical keywords are present in your resume!",
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
          fontStyle: FontStyle.italic,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildChartHeader() {
    return PremiumCard(
      height: 320,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CATEGORY MATCH RATE",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                    letterSpacing: 1.5,
                  ),
                ),
                // The View Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _showRadar = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: !_showRadar ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.bar_chart_rounded, 
                              size: 16, 
                              color: !_showRadar ? AppColors.primary : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showRadar = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _showRadar ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(Icons.radar_rounded, 
                              size: 16, 
                              color: _showRadar ? AppColors.primary : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child)),
                child: _showRadar 
                    ? CareerRadarWidget(
                        key: const ValueKey('radar'),
                        skills: widget.result.skillGapChart.map((e) => {
                          'name': e.name,
                          'value': e.percent.toDouble(),
                        }).toList(),
                      )
                    : BarChart(
                        key: const ValueKey('bar'),
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipPadding: EdgeInsets.all(12),
                              tooltipMargin: 8,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  "${widget.result.skillGapChart[group.x].name}\n",
                                  GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "${rod.toY.toInt()}% Match",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= widget.result.skillGapChart.length) {
                                    return SizedBox();
                                  }
                                  final name = widget.result.skillGapChart[value.toInt()].name;
                                  final label = widget.result.skillGapChart.length > 5
                                      ? (name.length > 3 ? name.substring(0, 3) : name)
                                      : name;
        
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    space: 8,
                                    angle: -0.8,
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: widget.result.skillGapChart.asMap().entries.map((entry) {
                            double percent = entry.value.percent.toDouble();
                            Color baseColor = percent < 40
                                ? Colors.redAccent
                                : (percent < 70 ? Colors.orangeAccent : Colors.greenAccent);
                            
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: percent,
                                  gradient: LinearGradient(
                                    colors: [
                                      baseColor.withValues(alpha: 0.6),
                                      baseColor,
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  width: 16,
                                  borderRadius: BorderRadius.circular(6),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: 100,
                                    color: baseColor.withValues(alpha: 0.05),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ).animate().scaleY(begin: 0, end: 1, duration: 600.ms, curve: Curves.easeOutBack),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGapTile(SkillGapData gap) {
    Color statusColor = gap.status == "Critical Gap"
        ? Colors.redAccent
        : (gap.status == "Warning" ? Colors.orangeAccent : Colors.greenAccent);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: GlassContainer.clearGlass(
        height: 120,
        width: double.infinity,
        borderRadius: BorderRadius.circular(16),
        blur: 15,
        borderWidth: 1,
        borderColor: statusColor.withValues(alpha: 0.2),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.6),
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                      )
                    ]
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    gap.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  "${gap.percent}%",
                  style: GoogleFonts.plusJakartaSans(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .shimmer(duration: 2000.ms, color: statusColor.withValues(alpha: 0.5)),
              ],
            ),
            SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: gap.percent / 100,
                backgroundColor: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.1),
                color: statusColor,
                minHeight: 8,
              ),
            ).animate().slideX(begin: -1, end: 0, duration: 800.ms, curve: Curves.easeOut),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${gap.matched} / ${gap.total} Skills Matched",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    gap.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 60),
          Icon(Icons.query_stats_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No Skill Data Found",
            style: GoogleFonts.plusJakartaSans(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Try analyzing a resume with a job description.",
            style: GoogleFonts.plusJakartaSans(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
