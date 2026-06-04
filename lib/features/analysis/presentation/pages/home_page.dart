import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/premium_widgets.dart';
import '../../../../widgets/job_match_radar.dart';
import '../../../../utils/file_validator.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/analysis_cubit.dart';
import '../../../history/presentation/bloc/history_cubit.dart';
import '../../../history/domain/entities/history_item.dart';
import 'dashboard_page.dart';
import '../../data/models/analysis_result_model.dart';
import '../../../../screens/job_tracker_screen.dart';
import '../../../../screens/interview_prep_screen.dart';
import '../../../../screens/job_matcher_screen.dart';
import '../../../../screens/career_accelerator_screen.dart';
import '../../../../screens/career_tips_screen.dart';
import '../../../../models/analysis_result.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _jdController = TextEditingController();
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final error = FileValidator.validateFile(file);

        if (error != null) {
          if (mounted) FileValidator.showErrorSnackBar(context, error);
          return;
        }

        setState(() => _selectedFile = file);
      }
    } catch (e) {
      if (mounted) FileValidator.showErrorSnackBar(context, "Error: $e");
    }
  }
  void _analyze() {
    if (_selectedFile == null || _jdController.text.trim().isEmpty) {
      FileValidator.showErrorSnackBar(context, "Upload resume & paste JD");
      return;
    }

    final jdText = _jdController.text.trim();
    final wordCount = jdText.split(RegExp(r'\s+')).length;

    // 1. Length check
    if (jdText.length < 80 || wordCount < 15) {
      FileValidator.showErrorSnackBar(
        context,
        "Job description is too short (min 80 characters / 15 words)",
      );
      return;
    }

    // 2. Check if the input is a URL
    final isUrl = jdText.startsWith("http://") || 
                  jdText.startsWith("https://") || 
                  jdText.startsWith("www.") || 
                  RegExp(r'^https?://[^\s]+$').hasMatch(jdText);
    if (isUrl) {
      final textLower = jdText.toLowerCase();
      final isGated = textLower.contains("linkedin.com") || 
                      textLower.contains("indeed.com") || 
                      textLower.contains("naukri.com") || 
                      textLower.contains("glassdoor.com") || 
                      textLower.contains("monster.com") || 
                      textLower.contains("ziprecruiter.com");
      if (isGated) {
        _showErrorDialog(
          "We cannot scrape job descriptions directly from auth-gated job portals (LinkedIn, Indeed, etc.). Please copy and paste the job description text instead.",
        );
      } else {
        _showErrorDialog(
          "Please copy and paste the job description text instead of using a link, as some links cannot be parsed successfully.",
        );
      }
      return;
    }

    // 3. Cover letter or Resume check
    final textLower = jdText.toLowerCase();
    final isCoverLetter = textLower.contains("dear hiring manager") || 
                          textLower.contains("dear recruiter") || 
                          textLower.contains("to whom it may concern") || 
                          textLower.contains("writing to apply");
    final isResume = textLower.contains("my name is") || 
                     (textLower.contains("resume") && 
                      textLower.contains("education") && 
                      textLower.contains("experience") && 
                      textLower.contains("skills"));

    if (isCoverLetter || isResume) {
      _showErrorDialog(
        "This looks like a cover letter or resume rather than a job description. Please paste a valid job description containing roles, responsibilities, or requirements instead.",
      );
      return;
    }

    context.read<AnalysisCubit>().analyzeResume(
      resumeFile: _selectedFile!,
      jdText: _jdController.text,
    );
  }
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AnalysisCubit, AnalysisState>(
          listener: (context, state) {
            if (state is AnalysisSuccess) {
              // Save to history
              context.read<HistoryCubit>().saveAnalysisResult(
                fileName: _selectedFile!.name,
                score: state.result.score,
                percentile: state.result.percentile,
                missingKeywords: state.result.missingKeywords,
                suggestions: state.result.suggestions,
                rawJson: jsonEncode(
                  (state.result as AnalysisResultModel).toJson(),
                ),
              );

              // Reset inputs
              setState(() {
                _selectedFile = null;
                _jdController.clear();
              });

              // Navigate to dashboard
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardPage(result: state.result),
                ),
              );
            } else if (state is AnalysisError) {
              _showErrorDialog(state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 32),
                    _buildMainScoreCard(),
                    SizedBox(height: 32),
                    _buildSectionTitle("PROFESSIONAL PULSE"),
                    SizedBox(height: 16),
                    _buildRadarSection(),
                    SizedBox(height: 32),
                    _buildSectionTitle("SCAN & OPTIMIZE"),
                    SizedBox(height: 16),
                    _buildScanAndOptimizeSection(),
                    SizedBox(height: 32),
                    _buildSectionTitle("CAREER TOOLS"),
                    SizedBox(height: 16),
                    _buildToolsGrid(),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        String name = "User";
        String email = "Ready to Rank";
        if (state is Authenticated) {
          name = state.user.fullName.split(' ')[0];
          email = state.user.email;
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E293B)
                      : Colors.grey.shade100,
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, $name!",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      email,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 22,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainScoreCard() {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        int score = 0;
        int percentile = 0;
        if (state is HistoryLoaded && state.history.isNotEmpty) {
          score = state.history.first.score;
          percentile = state.history.first.percentile;
        }
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D2B39B0),
                blurRadius: 30,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Rank",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      score > 0 ? "$score" : "--",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      score > 0
                          ? "Your resume is performing better than $percentile% of candidates."
                          : "Complete your first analysis to see your rank and market value.",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              score > 0
                  ? PremiumCircularScore(
                      score: score.toDouble(),
                      size: 100,
                      color: Colors.white,
                      showText: false,
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_fix_high_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
            ],
          ),
        ).animate().slideY(begin: 0.1, duration: 600.ms);
      },
    );
  }

  Widget _buildRadarSection() {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        Map<String, double> radarScores = {
          'Technical': 0.75,
          'Leadership': 0.65,
          'Experience': 0.85,
          'Soft Skills': 0.70,
          'Impact': 0.60,
        };
        String dynamicText = "Run your first analysis to replace this preview with your real AI-scored metrics.";
        bool isPlaceholder = true;

        if (state is HistoryLoaded && state.history.isNotEmpty) {
          final latestItem = state.history.first;
          final result = latestItem.toAnalysisResult();

          if (result.scoreBreakdown.isNotEmpty) {
            radarScores.clear();
            result.scoreBreakdown.forEach((key, value) {
              if (radarScores.length < 5) {
                radarScores[key] = (value as num).toDouble() / 100.0;
              }
            });

            if (radarScores.isNotEmpty) {
              isPlaceholder = false;
              final sortedEntries = radarScores.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final highest = sortedEntries.first.key;
              final lowest = sortedEntries.last.key;
              dynamicText =
                  "Your highest alignment is in $highest. Focus on $lowest metrics to reach the next tier.";
            }
          }
        }

        return PremiumCard(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              if (isPlaceholder)
                Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 12, color: AppColors.warning),
                        SizedBox(width: 6),
                        Text(
                          'SAMPLE PREVIEW',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              JobMatchRadar(scores: radarScores),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  dynamicText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms);
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.5),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildScanAndOptimizeSection() {
    return BlocBuilder<AnalysisCubit, AnalysisState>(
      builder: (context, state) {
        final isAnalyzing = state is AnalysisLoading;

        if (isAnalyzing) {
          return PremiumCard(
            height: 250,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Document Mockup
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contact_page_outlined, size: 80, color: AppColors.primary.withValues(alpha: 0.1)),
                      SizedBox(height: 16),
                      Text(
                        "AI is X-Raying your Resume...",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 1500.ms, color: AppColors.primary.withValues(alpha: 0.5)),
                      SizedBox(height: 8),
                      Text(
                        "Extracting skills, parsing keywords, matching JD...",
                        style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                // Glowing Scanning Line
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          blurRadius: 15,
                          spreadRadius: 3,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true)).slideY(begin: 0, end: 60, duration: 1200.ms, curve: Curves.easeInOutSine),
                // Random Floating "Detected" Chips
                Positioned(
                  top: 40,
                  left: 20,
                  child: _buildFloatingScanChip("Parsing Education...").animate(onPlay: (controller) => controller.repeat()).fadeIn(duration: 500.ms).then(delay: 1000.ms).fadeOut(duration: 500.ms),
                ),
                Positioned(
                  bottom: 60,
                  right: 20,
                  child: _buildFloatingScanChip("Mapping Skills...").animate(onPlay: (controller) => controller.repeat()).fadeIn(delay: 800.ms, duration: 500.ms).then(delay: 1000.ms).fadeOut(duration: 500.ms),
                ),
              ],
            ),
          ).animate().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack);
        }

        return Column(
          children: [
            _buildUploadWidget(),
            SizedBox(height: 16),
            _buildJdInput(),
            SizedBox(height: 20),
            _buildAnalyzeButton(isAnalyzing),
          ],
        );
      },
    );
  }

  Widget _buildFloatingScanChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 8),
        ],
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildUploadWidget() {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: _pickFile,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 100,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _selectedFile == null
                      ? Icons.cloud_upload_outlined
                      : Icons.check_circle_rounded,
                  color: _selectedFile == null
                      ? AppColors.primary
                      : Colors.teal,
                  size: 28,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFile == null
                          ? "Upload New Resume"
                          : _selectedFile!.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _selectedFile == null
                          ? "PDF format • Max 10MB"
                          : "File attached successfully",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedFile != null)
                IconButton(
                  onPressed: () => setState(() => _selectedFile = null),
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJdInput() {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: TextField(
        controller: _jdController,
        maxLines: 3,
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Paste job description or requirements here...",
          hintStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.4),
          ),
          contentPadding: EdgeInsets.all(20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(bool isAnalyzing) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isAnalyzing ? null : _analyze,
        child: Text("Run Rank Analysis"),
      ),
    );
  }

  Widget _buildToolsGrid() {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3, // Increased to prevent overflow
      children: [
        _buildToolCard(
          "Job Tracker",
          "Manage Apps",
          Icons.assignment_turned_in_rounded,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const JobTrackerScreen()),
          ),
        ),
        _buildToolCard(
          "Job Matcher",
          "Market Roles",
          Icons.work_outline_rounded,
          Color(0xFFEA580C),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const JobMatcherScreen()),
          ),
        ),
        _buildToolCard(
          "Market Insights",
          "Trends & Demand",
          Icons.auto_graph_rounded,
          Color(0xFF7C3AED),
          () {
            final historyState = context.read<HistoryCubit>().state;
            if (historyState is HistoryLoaded && historyState.history.isEmpty) {
              FileValidator.showErrorSnackBar(
                  context, "Run an analysis first to unlock Market Insights.");
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => CareerAcceleratorScreen(
                  result: _getLatestOrFallbackResult(context),
                  isMarketInsightsMode: true,
                ),
              ),
            );
          },
        ),
        _buildToolCard(
          "Career Hacks",
          "Cheat Codes",
          Icons.tips_and_updates_rounded,
          Color(0xFFF59E0B),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const CareerTipsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildToolCard(
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
          padding: EdgeInsets.all(12), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 13, // Slightly smaller
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySection() {
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoading)
          return Center(child: CircularProgressIndicator());
        if (state is HistoryLoaded) {
          if (state.history.isEmpty) return _buildEmptyState();
          return _buildActivityList(state.history);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildActivityList(List<HistoryItem> history) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (c, i) => SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = history[index];
        final timeAgo = _getTimeAgo(item.date);
        return InkWell(
          onTap: () {
            // Adapt to old result model for DashboardScreen
            // Navigator.push(context, MaterialPageRoute(builder: (c) => DashboardScreen(result: item.toAnalysisResult())));
          },
          borderRadius: BorderRadius.circular(24),
          child: PremiumCard(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.fileName,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Scanned $timeAgo",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${item.score}%",
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return "${diff.inDays}d ago";
    if (diff.inHours > 0) return "${diff.inHours}h ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m ago";
    return "just now";
  }

  Widget _buildEmptyState() {
    return PremiumCard(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 48,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B).withValues(alpha: 0.2),
            ),
            SizedBox(height: 16),
            Text(
              "No recent activity",
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Your career journey starts here.",
              style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    // Default values
    String title = "Analysis Error";
    String mainText = message;
    List<String> reasons = [];

    // Parse the backend validation format
    if (message.contains("Invalid Document:")) {
      title = "Invalid Document";
      final cleanMsg = message.replaceAll("Invalid Document:", "").trim();
      final parts = cleanMsg.split(". ");
      if (parts.isNotEmpty) {
        mainText = parts[0];
        reasons = parts.sublist(1).where((p) => p.trim().isNotEmpty).toList();
      }
    } else if (message.contains("Invalid Job Description:")) {
      title = "Invalid Job Description";
      final cleanMsg = message.replaceAll("Invalid Job Description:", "").trim();
      final parts = cleanMsg.split(". ");
      if (parts.isNotEmpty) {
        mainText = parts[0];
        reasons = parts.sublist(1).where((p) => p.trim().isNotEmpty).toList();
      }
    }

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titlePadding: const EdgeInsets.all(24),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        actionsPadding: const EdgeInsets.all(20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mainText,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            if (reasons.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...reasons.map((reason) {
                // Ensure dot at the end if not present
                final cleanReason = reason.endsWith(".") ? reason : "$reason.";
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, right: 8.0),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          cleanReason,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8) ?? const Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primary
                  : Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => Navigator.pop(c),
            child: Text(
              "Got it",
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  AnalysisResult _getLatestOrFallbackResult(BuildContext context) {
    final historyState = context.read<HistoryCubit>().state;
    if (historyState is HistoryLoaded && historyState.history.isNotEmpty) {
      try {
        final jsonStr = historyState.history.first.fullResultJson;
        if (jsonStr != null) {
          final Map<String, dynamic> decoded = jsonDecode(jsonStr);
          return AnalysisResult.fromJson(decoded);
        }
      } catch (_) {}
    }
    return AnalysisResult(
      score: 75,
      suggestions: ["Tailor your summary to match target role keywords."],
      careerGuidance: {
        'learning_roadmap': [
          {
            'role': 'Senior Software Engineer',
            'estimated_time': '6–12 months',
            'readiness': 70,
            'skills_to_add': [
              'System Design',
              'Cloud Architecture',
              'Distributed Systems',
            ],
          },
        ],
      },
      gapProjects: [
        {
          'skill': 'System Design',
          'project': 'Distributed Rate Limiter',
          'spec':
              'Design and implement a thread-safe, distributed token bucket rate limiter in Go/Python.',
        },
      ],
    );
  }
}
