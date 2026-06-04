import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_widgets.dart';

class JobMatcherScreen extends StatefulWidget {
  const JobMatcherScreen({super.key});

  @override
  State<JobMatcherScreen> createState() => _JobMatcherScreenState();
}

class _JobMatcherScreenState extends State<JobMatcherScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _hasAttemptedMatch = false;
  PlatformFile? _selectedFile;
  List<dynamic> _matches = [];
  String? _marketDemand;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
        _hasAttemptedMatch = false;
        _matches = [];
      });
    }
  }

  Future<void> _findMatches() async {
    if (_selectedFile == null) return;
    setState(() {
      _isLoading = true;
      _hasAttemptedMatch = true;
    });
    try {
      final response = await _apiService.getJobMatches(
        resumeFile: _selectedFile!,
      );
      setState(() {
        _matches = response['recommended_roles'] ?? [];
        _marketDemand = response['market_demand'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Market Insights",
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : (!_hasAttemptedMatch ? _buildUploadState() : _buildResultsState()),
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
            "Matching your profile with market opportunities...",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadState() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PremiumCard(
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.work_history_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
                SizedBox(height: 24),
                Text(
                  "Discover Your Market Value",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Upload your resume to see matching high-growth roles.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 32),
                _selectedFile == null
                    ? ElevatedButton(
                        onPressed: _pickFile,
                        child: Text("Select Resume"),
                      )
                    : Column(
                        children: [
                          Text(
                            _selectedFile!.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _findMatches,
                            child: Text("Find Best Matches"),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _selectedFile = null),
                            child: Text("Change File"),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsState() {
    if (_matches.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              SizedBox(height: 24),
              Text(
                "No Strong Matches Found",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "We couldn't find roles that match your current resume perfectly. Try updating your skills or uploading a different version.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B)),
              ),
              SizedBox(height: 32),
              TextButton.icon(
                onPressed: () => setState(() => _hasAttemptedMatch = false),
                icon: Icon(Icons.refresh_rounded),
                label: Text("Try Another Resume"),
              ),
            ],
          ),
        ),
      ).animate().fadeIn();
    }

    return ListView(
      padding: EdgeInsets.all(24),
      children: [
        const FeatureExplanationBanner(
          title: "Market Insights & Job Matching",
          description: "We've matched your resume against live job descriptions. See which roles offer the highest match rate, and which missing skills you should add to increase your chances of an interview.",
          icon: Icons.work_history_rounded,
        ),
        if (_marketDemand != null)
          PremiumCard(
            color: AppColors.primary.withValues(alpha: 0.05),
            hasShadow: false,
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded, color: AppColors.primary),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _marketDemand!,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: -0.1).fadeIn(),
        SizedBox(height: 24),
        Text(
          "Recommended Roles",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ..._matches.map((job) => _buildJobCard(job)),
      ],
    );
  }

  Widget _buildJobCard(dynamic job) {
    final List<dynamic> matched = job['matched_skills'] ?? [];
    final List<dynamic> missing = job['missing_skills'] ?? [];

    return PremiumCard(
      margin: EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${job['match']}%",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${job['location']} • ${job['salary']}",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) ?? Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Divider(),
          SizedBox(height: 8),
          _buildSkillSection("MATCHED SKILLS", matched, Colors.teal),
          SizedBox(height: 12),
          _buildSkillSection(
            "RECOMMENDED TO ADD",
            missing,
            Colors.orangeAccent,
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Application feature coming soon!"),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text("Quick Apply", style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildSkillSection(String title, List<dynamic> skills, Color color) {
    if (skills.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills
              .map(
                (s) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: color.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    s.toString(),
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
