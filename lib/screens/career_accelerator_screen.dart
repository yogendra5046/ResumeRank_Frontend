import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../models/analysis_result.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/career_radar_widget.dart';

class CareerAcceleratorScreen extends StatefulWidget {
  final AnalysisResult result;
  final bool isMarketInsightsMode;

  const CareerAcceleratorScreen({
    super.key,
    required this.result,
    this.isMarketInsightsMode = false,
  });

  @override
  State<CareerAcceleratorScreen> createState() =>
      _CareerAcceleratorScreenState();
}

class _CareerAcceleratorScreenState extends State<CareerAcceleratorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  // Salary Simulator variables
  final _offerAController = TextEditingController();
  final _offerBController = TextEditingController();
  late final TextEditingController _roleController;
  late final TextEditingController _skillController;
  late final TextEditingController _companyController;
  String _generatedSimulatorScript = '';

  // Market Insights variables
  bool _loadingMarket = true;
  Map<String, dynamic>? _marketInsights;
  String? _marketError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isMarketInsightsMode ? 2 : 3,
      vsync: this,
    );

    // Init Salary Simulator inputs
    _roleController = TextEditingController(
      text: widget.result.careerGuidance['next_best_move']?.toString() ?? '',
    );
    final topSkill = widget.result.matchedSkills.isNotEmpty == true
        ? (widget.result.matchedSkills.first['name'] as String? ?? '')
        : '';
    _skillController = TextEditingController(text: topSkill);
    _companyController = TextEditingController();

    _loadMarketInsights();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _offerAController.dispose();
    _offerBController.dispose();
    _roleController.dispose();
    _skillController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketInsights() async {
    try {
      final data = await _apiService.getMarketInsights();
      if (mounted) {
        setState(() {
          _marketInsights = data;
          _loadingMarket = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _marketError = e.toString();
          _loadingMarket = false;
        });
      }
    }
  }

  int? _parseInt(String s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), ''));

  void _generateSimulatorScript() {
    final offerA = _parseInt(_offerAController.text);
    final role = _roleController.text.isNotEmpty
        ? _roleController.text
        : 'this role';
    final skill = _skillController.text.isNotEmpty
        ? _skillController.text
        : 'my area of expertise';
    final company = _companyController.text.isNotEmpty
        ? _companyController.text
        : 'your organization';

    if (offerA == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Offer A salary to simulate negotiation.'),
        ),
      );
      return;
    }

    final targetRange = '${offerA + 3}–${offerA + 10} LPA';
    final projectNote = widget.result.gapProjects.isNotEmpty == true
        ? 'my work on ${widget.result.gapProjects.first['project'] ?? 'recent projects'}'
        : 'my relevant project experience';

    setState(() {
      _generatedSimulatorScript =
          '''Dear Hiring Team,

Thank you so much for extending the offer for the $role position. I am genuinely excited about the opportunity to contribute to $company.

After careful consideration of market data for $role positions and reflecting on my specific expertise in $skill, I would like to respectfully discuss the compensation. Based on current industry benchmarks and my background — particularly $projectNote — I was hoping we could explore a base salary in the range of $targetRange.

I am highly committed to this opportunity and believe I can deliver strong results from day one. I hope we can find a package that reflects both the market value and the value I bring to the team.

Would you be open to a brief conversation about this? I am flexible and happy to discuss.

Thank you again for your time and consideration.

Warm regards,
[Your Name]''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.isMarketInsightsMode
            ? "Market Insights & Simulation"
            : "Career Accelerator"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          tabs: widget.isMarketInsightsMode
              ? const [
                  Tab(text: "MARKET DEMAND", icon: Icon(Icons.trending_up_rounded)),
                  Tab(text: "SALARY SIMULATION", icon: Icon(Icons.calculate_rounded)),
                ]
              : const [
                  Tab(text: "GROWTH ROADMAP", icon: Icon(Icons.route_rounded)),
                  Tab(text: "PITCH SCRIPTS", icon: Icon(Icons.badge_rounded)),
                  Tab(
                    text: "PORTFOLIO PROJECTS",
                    icon: Icon(Icons.workspaces_rounded),
                  ),
                ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.isMarketInsightsMode
            ? [
                _buildMarketDemandTab(),
                _buildSalaryTab(),
              ]
            : [
                _buildRoadmapTab(),
                _buildScriptsTab(),
                _buildGapProjectsTab(),
              ],
      ),
    );
  }

  // TAB 1: ROADMAP & FUTURE-PROOF
  Widget _buildRoadmapTab() {
    final guidance = widget.result.careerGuidance;
    // Prefer the full multi-step roadmap, fall back to the single-step learning_roadmap
    final rawRoadmap = guidance['roadmap'] as List?;
    final roadmap = rawRoadmap != null && rawRoadmap.isNotEmpty
        ? rawRoadmap
        : (guidance['learning_roadmap'] as List? ?? []);
    final futureProof =
        (guidance['future_proof_analysis'] as Map<String, dynamic>?) ??
        {
          'score': 70,
          'verdict': 'Stable',
          'emerging_skills': <String>[],
          'legacy_skills': <String>[],
        };
    final industryAlign = (guidance['industry_alignment'] as List?) ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FeatureExplanationBanner(
            title: "Career Growth Roadmap",
            description: "A personalized step-by-step career path generated by AI based on the gap between your current resume and your target job description. We identify missing skills and provide actionable next steps to close the gap.",
            icon: Icons.route_rounded,
          ),
          _buildHeader("CAREER GROWTH RADAR", Icons.radar_rounded),
          SizedBox(height: 24),
          Center(
            child: CareerRadarWidget(
              skills: widget.result.skillGapChart
                  .map((s) => {'name': s.name, 'value': s.percent.toDouble()})
                  .toList()
                  .take(6)
                  .toList(),
            ),
          ),
          SizedBox(height: 32),
          _buildHeader("FUTURE-PROOF SCORE", Icons.auto_awesome_rounded),
          SizedBox(height: 16),
          _buildFutureProofCard(futureProof),
          SizedBox(height: 32),
          _buildHeader("PERSONALIZED ROADMAP", Icons.route_rounded),
          SizedBox(height: 24),
          ...roadmap.map((step) => _buildRoadmapStep(step)),
          SizedBox(height: 32),
          _buildHeader("INDUSTRY ALIGNMENT", Icons.business_rounded),
          SizedBox(height: 16),
          _buildIndustryAlignmentSection(industryAlign),
          SizedBox(height: 40),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildFutureProofCard(Map<String, dynamic> data) {
    final score = data['score'] ?? 0;
    final verdict = data['verdict'] ?? "Unknown";
    final emerging = List<String>.from(data['emerging_skills'] ?? []);
    final legacy = List<String>.from(data['legacy_skills'] ?? []);

    return PremiumCard(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                verdict.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                  fontSize: 12,
                ),
              ),
              Text(
                "$score%",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              color: AppColors.primary,
              minHeight: 8,
            ),
          ),
          SizedBox(height: 20),
          if (emerging.isNotEmpty) ...[
            Text(
              "EMERGING SKILLS DETECTED",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: emerging
                  .map(
                    (s) => Chip(
                      label: Text(s, style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.green.withValues(alpha: 0.05),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (legacy.isNotEmpty) ...[
            SizedBox(height: 16),
            Text(
              "LEGACY RISK SKILLS",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: legacy
                  .map(
                    (s) => Chip(
                      label: Text(s, style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.red.withValues(alpha: 0.05),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoadmapStep(Map<String, dynamic> step) {
    final roleName =
        step['skill'] ??
        step['role'] ??
        step['title'] ??
        step['step'] ??
        step['name'] ??
        "Next Move";
    final timeStr =
        step['estimated_time'] ?? step['timeframe'] ?? step['time'] ?? "";
    final readinessScore =
        step['readiness'] ?? step['score'] ?? step['match'] ?? 0;
    final skillsToAdd =
        step['skills_to_add'] ??
        step['skills'] ??
        step['topics'] ??
        step['key_skills'] ??
        [];

    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: PremiumCard(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            roleName.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (timeStr.toString().isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              timeStr.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Readiness: $readinessScore%",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "SKILLS TO ADD:",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (skillsToAdd as List)
                          .map<Widget>(
                            (s) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                s.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndustryAlignmentSection(List<dynamic> alignments) {
    if (alignments.isEmpty) {
      return PremiumCard(
        hasShadow: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No industry alignment data available.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }
    return Column(
      children: alignments.map((a) {
        if (a is! Map) return const SizedBox.shrink();
        final fitScore = (a['fit_score'] as num? ?? 0).toDouble();
        final industry = a['industry']?.toString() ?? 'Unknown';
        return PremiumCard(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: fitScore / 100,
                  strokeWidth: 4,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      industry,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Alignment: ${fitScore.toInt()}%',
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
      }).toList(),
    );
  }

  // TAB 2: MARKET DEMAND
  Widget _buildMarketDemandTab() {
    if (_loadingMarket) {
      return Center(child: CircularProgressIndicator());
    }

    if (_marketError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Failed to load market insights',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _marketError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadMarketInsights,
                icon: Icon(Icons.refresh_rounded),
                label: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final roles = (_marketInsights?['trending_roles'] as List?) ?? [];
    final skills = (_marketInsights?['hot_skills'] as List?) ?? [];
    final forecast = (_marketInsights?['growth_forecast'] as List?) ?? [];

    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        const FeatureExplanationBanner(
          title: "Live Market Intelligence",
          description: "We scrape real-time market data to show you exactly which skills and roles are trending in your specific industry. Use this to focus your learning on high-demand, high-ROI topics.",
          icon: Icons.trending_up_rounded,
        ),
        PremiumCard(
          padding: EdgeInsets.all(24),
          color: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _marketInsights?['market_state'] ?? 'Live Market Analysis',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Demand Intelligence',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _buildStatItem(
                    'JOBS ANALYZED',
                    '${_marketInsights?['total_jobs_analyzed'] ?? 'N/A'}',
                  ),
                  SizedBox(width: 32),
                  _buildStatItem('TRENDING ROLES', '${roles.length}'),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        _buildHeader('Trending Roles', Icons.auto_graph_rounded),
        SizedBox(height: 16),
        ...roles.asMap().entries.map(
          (entry) => _buildRoleCard(entry.value, entry.key),
        ),
        SizedBox(height: 32),
        if (forecast.isNotEmpty) ...[
          _buildHeader('Growth Forecast', Icons.speed_rounded),
          SizedBox(height: 16),
          ...forecast.map((item) => _buildDynamicForecastCard(item)),
          SizedBox(height: 32),
        ],
        _buildHeader('In-Demand Skills', Icons.psychology_rounded),
        SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: skills.map<Widget>((s) => _buildSkillChip(s)).toList(),
        ),
        SizedBox(height: 40),
      ],
    ).animate().fadeIn();
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard(dynamic role, int index) {
    if (role is! Map) return const SizedBox.shrink();
    final roleName =
        role['role']?.toString() ?? role['title']?.toString() ?? 'Unknown Role';
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '#${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              roleName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Icon(
            Icons.trending_up_rounded,
            color: Colors.greenAccent,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicForecastCard(dynamic item) {
    if (item is! Map) return const SizedBox.shrink();
    final sector =
        item['sector']?.toString() ?? item['role']?.toString() ?? 'Unknown';
    final demand = item['demand']?.toString() ?? 'Growing';
    final growth =
        (item['growth_percent'] as num? ?? item['growth'] as num? ?? 0).toInt();

    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sector,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Demand: $demand',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+$growth%',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'PROJECTED',
                style: TextStyle(fontSize: 8, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(dynamic skill) {
    if (skill is! Map) return const SizedBox.shrink();
    final skillName =
        skill['skill']?.toString() ?? skill['name']?.toString() ?? '';
    final count = skill['count'] ?? skill['demand'] ?? '';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skillName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (count != '') ...[
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // TAB 3: SALARY SIMULATOR
  Widget _buildSalaryTab() {
    final a = _parseInt(_offerAController.text);
    final b = _parseInt(_offerBController.text);
    final diff = (a != null && b != null) ? (b - a) : null;

    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FeatureExplanationBanner(
            title: "Salary Negotiation Simulator",
            description: "Never leave money on the table. Enter your current offer, and our AI will generate a tailored, professional email script you can use to negotiate higher pay based on your unique skills and market value.",
            icon: Icons.calculate_rounded,
          ),
          Text(
            'OFFER COMPARISON',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PremiumCard(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Offer A',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _offerAController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'LPA',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    if (diff != null)
                      Text(
                        diff >= 0 ? '+$diff LPA' : '$diff LPA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: diff >= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    Icon(
                      Icons.compare_arrows_rounded,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PremiumCard(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Offer B',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _offerBController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'LPA',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (diff != null) ...[
            SizedBox(height: 12),
            PremiumCard(
              hasShadow: false,
              color: (diff >= 0 ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.05),
              padding: EdgeInsets.all(12),
              child: Text(
                diff >= 0
                    ? 'Offer B is $diff LPA higher. Use Offer A as your anchor when negotiating.'
                    : 'Offer A is ${diff.abs()} LPA higher. Offer B may need negotiation.',
                style: TextStyle(
                  fontSize: 12,
                  color: diff >= 0 ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          SizedBox(height: 32),
          PremiumCard(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONTEXT FOR NEGOTIATION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 16),
                _buildField(
                  _roleController,
                  'Role Title',
                  'e.g. Frontend Engineer',
                ),
                SizedBox(height: 12),
                _buildField(
                  _skillController,
                  'Key Strength / Skill',
                  'e.g. Flutter, API Design',
                ),
                SizedBox(height: 12),
                _buildField(
                  _companyController,
                  'Company Name',
                  'e.g. Acme Tech',
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NEGOTIATION SCRIPT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _generateSimulatorScript,
                icon: Icon(Icons.auto_awesome_rounded, size: 16),
                label: Text(
                  'Simulate Script',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          if (_generatedSimulatorScript.isNotEmpty)
            PremiumCard(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _generatedSimulatorScript,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.7,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.copy_rounded, size: 16),
                        label: Text('Copy Script'),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: _generatedSimulatorScript),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Negotiation script copied!'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            PremiumCard(
              color: AppColors.primary.withValues(alpha: 0.03),
              hasShadow: false,
              padding: EdgeInsets.all(20),
              child: Text(
                'Fill in Offer A and context details above, then tap "Simulate Script".',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          SizedBox(height: 40),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 13,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade400
                  : Colors.grey.shade500,
              fontSize: 12,
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black26
                : Colors.grey.shade100,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // TAB 4: PITCH SCRIPTS (Outreach, Negotiation, & Bio combined)
  Widget _buildScriptsTab() {
    final templates = widget.result.outreachTemplates;
    final scripts = widget.result.negotiationScripts;

    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        const FeatureExplanationBanner(
          title: "Pitch Scripts & Outreach",
          description: "Cold messaging recruiters and hiring managers is the fastest way to get an interview. We've generated highly personalized LinkedIn outreach and negotiation templates based specifically on your background.",
          icon: Icons.badge_rounded,
        ),
        _buildHeader("CULTURE SUMMARY BIO", Icons.auto_awesome_rounded),
        SizedBox(height: 12),
        _buildTemplateCard("Personal Biography", widget.result.cultureBio),
        SizedBox(height: 32),
        _buildHeader(
          "NETWORKING OUTREACH PLAYBOOK",
          Icons.mail_outline_rounded,
        ),
        SizedBox(height: 12),
        if (templates.isEmpty)
          PremiumCard(
            color: AppColors.primary.withValues(alpha: 0.04),
            hasShadow: false,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.mail_outline_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Text('Outreach Templates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Outreach templates are generated as part of the analysis and personalized to your JD. Re-run analysis with a detailed job description to generate compelling outreach messages.',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 13, height: 1.5),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '💡 Tip: Include company name, role title, and key requirements in your JD for more personalized outreach scripts.',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          )
        else
          ...templates.map(
            (t) => _buildTemplateCard(
              t['type'] ?? t['title'] ?? 'Template',
              t['message'] ?? t['content'] ?? '',
            ),
          ),
        SizedBox(height: 32),
        _buildHeader("OFFER NEGOTIATION SCRIPTS", Icons.handshake_outlined),
        SizedBox(height: 12),
        if (scripts.isEmpty)
          PremiumCard(
            color: AppColors.primary.withValues(alpha: 0.04),
            hasShadow: false,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.handshake_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Text('Negotiation Scripts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Salary negotiation scripts are personalized to your detected role and matched skills. Re-run analysis with a job description that includes salary details or role expectations.',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B), fontSize: 13, height: 1.5),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    '💰 Use the SALARY SIMULATION tab (via Home Tools → Market Insights) to generate a full negotiation script with a specific offer amount.',
                    style: TextStyle(fontSize: 12, height: 1.5, color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              ],
            ),
          )
        else
          ...scripts.map(
            (s) => _buildTemplateCard(
              s['scenario'] ?? s['title'] ?? 'Script',
              s['script'] ?? s['content'] ?? '',
            ),
          ),
      ],
    ).animate().fadeIn();
  }

  // TAB 5: PORTFOLIO PROJECTS
  Widget _buildGapProjectsTab() {
    final projects = widget.result.gapProjects;

    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        const FeatureExplanationBanner(
          title: "Portfolio Project Ideas",
          description: "Theoretical knowledge isn't enough. Our AI analyzed your missing skills and designed custom, highly-relevant portfolio projects you can build to prove to recruiters that you actually possess these skills.",
          icon: Icons.workspaces_rounded,
        ),
        ...projects.map((project) => PremiumCard(
              margin: EdgeInsets.only(bottom: 16),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                project['skill']?.toUpperCase() ?? "",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              SizedBox(height: 8),
              Text(
                project['project'] ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 12),
              Text(
                project['spec'] ?? "",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    ).animate().fadeIn();
  }

  Widget _buildTemplateCard(String title, String content) {
    return PremiumCard(
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
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Copied to clipboard!")),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            content,
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
